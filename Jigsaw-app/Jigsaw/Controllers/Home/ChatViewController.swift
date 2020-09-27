//
//  ChatViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Photos

// Firebase user, FireStore database, object storage
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Chatroom UI
import MessageKit
import InputBarAccessoryView
import PINRemoteImage
import Agrume

class ChatViewController: MessagesViewController {
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    if let inputBarButtonItem = item as? InputBarButtonItem {
                        inputBarButtonItem.isEnabled = !self.isSendingPhoto
                    }
                }
            }
        }
    }
    
    private var messagesReference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    private var messages = [Message]()
    private var messageListener: ListenerRegistration?
    
    private let user: User
    private let chatroom: Chatroom
    
    private var timer: Timer?
    var timeLeft: TimeInterval?
    
    var chatroomUserIDs = [String]()
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .second
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    deinit {
        finish()
        messageListener?.remove()
    }
    
    init(user: User, chatroom: Chatroom, timeLeft: TimeInterval?) {
        self.user = user
        self.chatroom = chatroom
        self.timeLeft = timeLeft
        super.init(nibName: nil, bundle: nil)
        self.title = chatroom.name
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = chatroom.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        messagesReference = FirebaseConstants.database.collection(["Chatrooms", id, "messages"].joined(separator: "/"))
        
        messageListener = messagesReference?.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
        
        maintainPositionOnKeyboardFrameChanged = true
        //        messageInputBar.inputTextView.tintColor = .accentColor
        //        messageInputBar.sendButton.setTitleColor(.accentColor, for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.image = UIImage(systemName: "camera")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed),
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    func start() {
        // If countdown remaining time specified, create a timer.
        if timeLeft != nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let time = self?.timeLeft else { return }
                self?.timeLeft = time.advanced(by: -1)
                DispatchQueue.main.async {
                    self?.messageInputBar.inputTextView.placeholder = (self?.timeFormatter.string(from: time) ?? "nil") + " remaining"
                }
            }
        }
    }
    
    func finish() {
        timer?.invalidate()
        timer = nil
    }
    
    private func getUserPiece(uid: String) -> JigsawPiece {
        let piece: JigsawPiece
        if let currentUserIndex = chatroomUserIDs.firstIndex(of: uid) {
            piece = JigsawPiece(index: currentUserIndex)
        } else {
            piece = .unknown
        }
        return piece
    }
    
    // MARK: - Actions
    
    @objc
    private func cameraButtonPressed(_ sender: InputBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //            picker.sourceType = .camera
        //        } else {
        //            picker.sourceType = .photoLibrary
        //        }
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func save(_ message: Message) {
        messagesReference?.addDocument(data: message.representation) { [weak self] error in
            if let error = error {
                self?.presentAlert(error: error)
                return
            }
            self?.messagesCollectionView.scrollToBottom()
            self?.messageInputBar.sendButton.stopAnimating()
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        // Anti network jitter.
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            insertNewMessage(message)
        default:
            break
        }
    }
    
    private func uploadImage(_ image: UIImage, to channel: Chatroom, completion: @escaping (URL?) -> Void) {
        guard let channelID = channel.id else {
            completion(nil)
            return
        }
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let imageRef = storage.child(channelID).child(imageName)
        imageRef.putData(data, metadata: metadata) { metadata, _ in
            guard metadata != nil else {
                completion(nil)
                return
            }
            // Async fetch the download URL.
            imageRef.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        
        uploadImage(image, to: chatroom) { [weak self] url in
            guard let self = self else {
                return
            }
            self.isSendingPhoto = false
            
            guard let url = url else {
                return
            }
            
            var message = Message(user: self.user, imageURL: url)
            message.downloadURL = url
            
            self.save(message)
            self.messagesCollectionView.scrollToBottom()
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? messagesCollectionView.tintColor : .systemGray3
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            imageView.pin_updateWithProgress = true
            imageView.pin_setImage(from: media.url)
        default:
            break
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let piece = getUserPiece(uid: message.sender.senderId)
        avatarView.setImage(UIImage(named: piece.bundleName)!)
        avatarView.backgroundColor = .clear
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        let message = messageForItem(at: messagesCollectionView.indexPath(for: cell)!, in: messagesCollectionView)
        switch message.kind {
        case .photo(let media):
            let agrume = Agrume(url: media.url!)
            agrume.background = .blurred(.regular)
            agrume.show(from: self)
        default:
            break
        }
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        let piece = getUserPiece(uid: user.uid)
        return ChatUser(senderId: user.uid, displayName: piece.label, jigsawValue: Profiles.jigsawValue)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Display time every 10 messages.
        if indexPath.section % 10 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let senderPiece = getUserPiece(uid: message.sender.senderId)
        return NSAttributedString(
            string: senderPiece.label,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.systemGray3
            ]
        )
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        UIFont.preferredFont(forTextStyle: .caption1).capHeight * 2
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 10 == 0 {
            return UIFont.boldSystemFont(ofSize: 10).capHeight * 2
        }
        return 0
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        messageInputBar.sendButton.startAnimating()
        let message = Message(user: user, content: text)
        save(message)
        // Clear the input field after sending the message.
        inputBar.inputTextView.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[.phAsset] as? PHAsset { // 1
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, _ in
                guard let image = result else {
                    return
                }
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage { // 2
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
