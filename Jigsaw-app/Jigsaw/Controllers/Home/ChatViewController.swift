//
//  ChatViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Photos

// Firebase User, FireStore realtime database, object storage
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Chatroom UI
import MessageKit
import InputBarAccessoryView
import PINRemoteImage
import Agrume

class ChatViewController: MessagesViewController {
    // MARK: Properties
    
    /// An array of chatroom users, set by the parent view controller.
    var chatroomUserIDs = [String]()
    
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                // Disable user interaction when sending photo.
                self.messageInputBar.isUserInteractionEnabled = !self.isSendingPhoto
                // Set the bar to semi-transparent when sending photo.
                self.messageInputBar.alpha = !self.isSendingPhoto ? 1 : 0.5
            }
        }
    }
    /// A reference to the chatroom messages collection.
    private var messagesReference: CollectionReference?
    /// A listener to the messages collection.
    private var messageListener: ListenerRegistration?
    /// The current user in the chatroom.
    private let user: User
    /// The current chatroom struct.
    private let chatroom: Chatroom
    /// An array to hold all chat messages.
    private var chatMessages = [Message]()
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .second
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    // MARK: Initializers
    
    deinit {
        messageListener?.remove()
        print("✅ chatroom deinit")
    }
    
    init(user: User, chatroom: Chatroom) {
        self.user = user
        self.chatroom = chatroom
        super.init(nibName: nil, bundle: nil)
        title = chatroom.name
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a join message to the chatroom.
        sendControlMessage(type: .join)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Send a left message when leaving the chatroom.
        sendControlMessage(type: .leave)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = chatroom.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        messagesReference = FirebaseConstants.database.collection(["Chatrooms", id, "messages"].joined(separator: "/"))
        
        messageListener = messagesReference?.addSnapshotListener { [weak self] querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
        
        maintainPositionOnKeyboardFrameChanged = true
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
    
    // MARK: - Actions
    
    @objc
    private func cameraButtonPressed(_ sender: InputBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}

// MARK: - Helpers

extension ChatViewController {
    private func getUserPiece(uid: String) -> JigsawPiece {
        let piece: JigsawPiece
        if let currentUserIndex = chatroomUserIDs.firstIndex(of: uid) {
            piece = JigsawPiece(index: currentUserIndex)
        } else {
            piece = .unknown
        }
        return piece
    }
    
    private func getMetaMessage(at indexPath: IndexPath) -> ControlMetaMessage? {
        let message = chatMessages[indexPath.section]
        return ControlMetaMessage(rawValue: message.content)
    }
    
    private func save(_ message: Message) {
        messagesReference?.addDocument(data: message.representation) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
                return
            }
            self.messagesCollectionView.scrollToBottom()
            self.messageInputBar.sendButton.stopAnimating()
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        // Anti network jitter.
        guard !chatMessages.contains(message) else { return }
        
        chatMessages.append(message)
        chatMessages.sort()
        
        let isLatestMessage = chatMessages.firstIndex(of: message) == (chatMessages.count - 1)
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
        let imageRef = FirebaseConstants.shared.chatroomStorage.child(channelID).child(imageName)
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
            guard let self = self, let url = url else { return }
            self.isSendingPhoto = false
            
            let message = Message(user: self.user, imageURL: url)
            self.save(message)
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func sendControlMessage(type: ControlMetaMessage) {
        let message = Message(user: user, controlMetaMessage: type)
        save(message)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? messagesCollectionView.tintColor : .systemGray3
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        false
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
        CGSize(width: 0, height: 8)
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    /// Dismiss the keyboard when tapping on the background.
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    /// Preview the image with Argume when tapping an image.
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
        chatMessages.count
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        chatMessages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = chatMessages[indexPath.section]
        if let metaMessage = ControlMetaMessage(rawValue: message.content) {
            // Replace the control message with emoji.
            switch metaMessage {
            case .join:
                return Message(message: message, content: "🧩")
            case .leave:
                return Message(message: message, content: "👋")
            }
        } else {
            return message
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Display control metadata.
        switch message.kind {
        case .text:
            let piece = getUserPiece(uid: message.sender.senderId)
            if let metaMessage = getMetaMessage(at: indexPath) {
                let string: String
                switch metaMessage {
                case .join:
                    string = "\(piece.label) joined the conversation"
                case .leave:
                    string = "\(piece.label) has moved on to the quiz"
                }
                return NSAttributedString(
                    string: string,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 10),
                        .foregroundColor: UIColor.darkGray
                    ]
                )
            }
        default:
            break
        }
        
        // If no control data, display time every 10 messages.
        if indexPath.section % 10 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        // Otherwise, do not display cell top label.
        return nil
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        // Display control metadata.
        switch message.kind {
        case .text:
            if getMetaMessage(at: indexPath) != nil {
                return UIFont.systemFont(ofSize: 10).capHeight * 2
            }
        default:
            break
        }
        // Display send date.
        if indexPath.section % 10 == 0 {
            return UIFont.boldSystemFont(ofSize: 10).capHeight * 2
        }
        // Do not display top label.
        return 0
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
