//
//  ChatViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
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
    /// Enter demo game
    private var isDemo: Bool
    /// Current room for a game.
    var currentGameRoom: Int?
    /// Game Currently being played by the player
    var gameOfMyGroup: GameOfGroup?
    /// Indicates if current chatroom is reported or not
    var isChatroomReported: Bool
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .second
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    // MARK: Initializers
    
    deinit {
        messageListener?.remove()
        os_log(.info, "✅ chatroom deinit")
    }
    
    init(user: User, chatroom: Chatroom, isDemo: Bool = false) {
        self.user = user
        self.chatroom = chatroom
        self.isDemo = isDemo
        self.isChatroomReported = false
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = chatroom.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        self.setupQuizButton()
        self.setupReportActivityButton()
        self.chatroomFirestoreSetup(id)
        self.messageInputBarSetup()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    @objc
    func back(sender: UIBarButtonItem) {
        let confirmationAlert = UIAlertController(title: Strings.ChatViewController.ConfirmationAlert.title, message: Strings.ChatViewController.ConfirmationAlert.message, preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.sendControlMessage(type: .leave)
            self.navigationController?.popViewController(animated: true)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    /// Creates and shows the 'Report Activity' button on Chatroom window.
    fileprivate func setupReportActivityButton() {
        // Prevent the 'Report Activity' button from showing up in Demo Mode
        if !isDemo && chatroomUserIDs.count == 2{
            let newReportButton = UIBarButtonItem(title: "Report Activity", style: .plain, target: self, action: #selector(reportButton))
            newReportButton.tintColor = .red
            self.navigationItem.rightBarButtonItem = newReportButton
        }
    }
    
    /// Responsible for creating and showing the 'Quiz' button on the Chatroom
    fileprivate func setupQuizButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Quiz", style: .plain, target: self, action: #selector(ChatViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    /// Responsible for initializing FireStore Chatroom Collection Ref and
    /// a listener for real-time updates to the same.
    /// - Parameter chatroomID: Chatroom in which changes are being recorded
    fileprivate func chatroomFirestoreSetup(_ chatroomID: String) {
        messagesReference = FirebaseConstants.chatroomMessagesRef(chatroomID: chatroomID)
        messageListener = messagesReference?.addSnapshotListener { [weak self] querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    /// Reponsible for setting up the Chat windows' input bar's send button.
    fileprivate func messageInputBarSetup() {
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.inputTextView.placeholder = Strings.ChatViewController.MessageInputBar.InputTextView.placeholder
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        messageInputBar.delegate = self
    }
}

// MARK: - Helpers
func binarySearch<T:Comparable>(_ inputArr:Array<T>, _ searchItem: T) -> Int? {
    var lowerIndex = 0
    var upperIndex = inputArr.count - 1
    
    while (true) {
        let currentIndex = (lowerIndex + upperIndex)/2
        if(inputArr[currentIndex] == searchItem) {
            return currentIndex
        } else if (lowerIndex > upperIndex) {
            return nil
        } else {
            if (inputArr[currentIndex] > searchItem) {
                upperIndex = currentIndex - 1
            } else {
                lowerIndex = currentIndex + 1
            }
        }
    }
}

extension ChatViewController {
    
    /// This function presents a `UIAlertController` on pressing the
    /// 'Report User'/'Report Chat' option that pops up on pressing the
    /// 'Report Activity' button in the chatroom
    fileprivate func confirmReportUIAlertController(_ thing: String) {
        let uialertcontroller = UIAlertController(title: "Confirm Report", message: "\(thing) successfully reported. Please press 'Cancel -> Quit Game' on the Quiz Page to exit and be depaired with the other player.", preferredStyle: .alert)
        uialertcontroller.addAction(UIAlertAction(title: "Got it.", style: .default, handler:{ _ in
            self.back(sender: UIBarButtonItem())
        }))
        self.present(uialertcontroller, animated: true)
    }
    
    /// Function to get the userID of the other player in the Game Room
    /// - Returns: String: Containing other player's user ID
    fileprivate func getOtherPlayerInGameRoom() -> String? {
        for currentUser in chatroomUserIDs{
            if(currentUser != user.uid && chatroomUserIDs.count == 2){
                // Found the user to be reported
                return currentUser
            }
        }
        return nil
    }
    
    /// Report the other user in the chat
    /// Works on the assumption that there are only two players in the chat
    /// including the current user.
    fileprivate func reportUser(){
        let userBeingReported: String? = self.getOtherPlayerInGameRoom()
        
        // Now that we have the user that is going to be reported
        // Create a document in the ReportedUsers Collection in Firebase
        // for further action
        
        guard let userBeingReported = userBeingReported else{
            os_log("Some kind of unexpected error occured while trying to fetch the other player's details from the database")
            return
        }
        
        // Retrieve the document's reference from Firebase
        let otherPlayerDbRef = FirebaseConstants.players.document(userBeingReported)
        
        // Retrieve the other player's details from Firebase to create another
        // entry in the ReportedPlayers Collection
        otherPlayerDbRef.getDocument{ document, error in
            if let document = document{
                // Got the document for the other player in the chatroom
                let data = document.data()
                guard let data = data else{
                    os_log(.error, "Document of the other player \(userBeingReported) contains corrupted data")
                    return
                }
                // Create a new entry for the player being reported in the database
                FirebaseConstants.reportedPlayers.document(userBeingReported).setData(data)
                // Show a confirmation message for the report
                self.confirmReportUIAlertController("User")
            }
            else{
                os_log(.debug, "Document doesn't contain any data, check database")
            }
        }
    }
    
    /// This function copies all the data from the document referece to the
    /// ReportedChatroom collection in Firebase
    fileprivate func copyChatroomDocuments(_ chatroomDocRef: DocumentReference){
        let chatroomID = chatroomDocRef.documentID
        
        chatroomDocRef.getDocument{ document, error in
            if let document = document{
                // Got the document
                guard let data = document.data() else{
                    os_log(.error, "Firebase document with chatroom id: \(chatroomID) has corrupt/null data")
                    return
                }
                let reportedChatroomRef = FirebaseConstants.reportedChatrooms.document(chatroomID)
                // Create a copy of this document in the ReportedChatrooms Collection
                reportedChatroomRef.setData(data)
                self.messagesReference?.getDocuments{ querySnapshot, error in
                    //
                    if let querySnapshot = querySnapshot {
                        // For each message document in the chatroom's messages
                        // collection, upload them to the reported chatroom collection
                        for document in querySnapshot.documents {
                            FirebaseConstants.reporteChatroomMessagesRef(chatroomID: chatroomID).document(document.documentID).setData(document.data())
                        }
                    }
                    else{
                        os_log(.error, "Couldn't upload messages from Chatroom: \(chatroomID) to ReportedChatrooms Collection")
                    }
                }
                // Show a confirmation message showing the chat has been reported
                self.confirmReportUIAlertController("Chat")
            }
            else{
                // Somehow we didn't get the document even though it exists in Firebase
                os_log(.error, "Unable to fetch chatroom document with id: \(chatroomID)")
            }
        }
    }
    
    
    @objc
    /// 'Reports' the current chatroom by creating a copy of the current
    /// chatroom in the 'ReportedChatrooms' collection in Firebase.
    fileprivate func reportChat(){
        self.isChatroomReported = true
        
        guard let chatroomID = chatroom.id else{
            os_log(.debug, "Chatroom ID doesn't exist.")
            return
        }
        
        // Document reference for the chatroom user is currently in
        let chatroomDocRef = FirebaseConstants.chatrooms.document(chatroomID)
        self.copyChatroomDocuments(chatroomDocRef)
    }
    
    
    @objc
    /// This function is responsible for creating a `UIAlertController`
    /// which handles the 'Report Activity' button of the chatroom.
    private func reportButton(){
        let actionController = UIAlertController(title: "Report Activity", message: "Please select an appropriate option from below: ", preferredStyle: .actionSheet)
        let reportUserAction = UIAlertAction(title: "Report User", style: .destructive){_ in
            // Present confirmation alert to the user for the report
            self.reportUser()
        }
        // Once a user presses this button, the collection 'isReported' gets updated in firestore
        // and the game exits
        let reportChatAction = UIAlertAction(title: "Report Chat", style: .destructive){_ in
            // Driver function for reporting the chat
            self.reportChat()
        }
        let cancelReportAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionController.addAction(reportUserAction)
        actionController.addAction(reportChatAction)
        actionController.addAction(cancelReportAction)
        self.present(actionController, animated: true)
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
            self.messagesCollectionView.scrollToLastItem()
            self.messageInputBar.sendButton.stopAnimating()
        }
    }
    
    private func didReceiveUserMessage() {
        let robot = ChatUser(senderId: "robot", displayName: "Robot", jigsawValue: Profiles.jigsawValue)
        srand48(Int(Date().timeIntervalSince1970))
        //        let randomNumber = Int(arc4random_uniform(UInt32(botMsg.count)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            guard let gameOfMyGroup = self.gameOfMyGroup else{                return
            }
            
            guard let demoGameChatbotMessages = demoChatbotMessages[gameOfMyGroup.gameName] else{
                return
            }
            
            guard let messageContent = demoGameChatbotMessages[self.currentGameRoom!] else{
                return
            }
            
            let robotMsg = Message(user: robot, content: messageContent)
            
            self.chatMessages.append(robotMsg)
            self.chatMessages.sort()
            
            //            let isLatestMessage2 = self.chatMessages.firstIndex(of: robotMsg) == (self.chatMessages.count - 1)
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    /// This function filters the message for objectionable words using the
    /// `censorWordList` as a reference.
    /// - Parameter message: Message that is currently being sent
    /// - Returns: Message with filtered content
    private func censorMessage(_ message: Message) -> Message{
        // Create a new message with the filtered content
        
        var messageContentStr: String = message.content
        var messageContentStrList = messageContentStr.components(separatedBy: CharacterSet.whitespaces)
        for currentIndex in 0..<messageContentStrList.capacity{
            if(binarySearch(profaneWordList, messageContentStrList[currentIndex].lowercased()) != nil){
                messageContentStrList[currentIndex] = "****"
            }
        }
        messageContentStr = String(messageContentStrList.joined(by: " "))
        return Message(message: message, content: messageContentStr)
    }
    
    private func insertNewMessage(_ message: Message) {
        // Anti network jitter.
        guard !chatMessages.contains(message) else { return }
        
        let newMessage = censorMessage(message)
        chatMessages.append(newMessage)
        chatMessages.sort()
        
        //        let isLatestMessage = chatMessages.firstIndex(of: message) == (chatMessages.count - 1)
        
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        // If the Chatroom is reported, for every new message sent to the
        // chatroom, create a copy in the ReportedChatroom's messages
        // subcollection.
        // ReportedChatroom -> chatroom.id -> messages
        if isChatroomReported{
            guard let chatroomID = chatroom.id else{
                os_log(.error, "Chatroom has null value")
                return
            }
            FirebaseConstants.reporteChatroomMessagesRef(chatroomID: chatroomID).document(change.document.documentID).setData(change.document.data())
        }
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
    
    private func sendControlMessage(type: ControlMetaMessage) {
        let message = Message(user: user, controlMetaMessage: type)
        save(message)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if getMetaMessage(at: indexPath) != nil {
            return UIColor.darkGray
        }
        
        return isFromCurrentSender(message: message) ? messagesCollectionView.tintColor : .systemGray3
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if getMetaMessage(at: indexPath) != nil {
            return .bubble
        }
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
        let piece = getUserPiece(uid: message.sender.senderId)
        if let metaMessage = ControlMetaMessage(rawValue: message.content) {
            // Replace the control message with emoji.
            let content: String
            switch metaMessage {
            case .join:
                content = "\(piece.label) has joined the chat"
            case .leave:
                content = "\(piece.label) has left the chat to take the quiz"
            }
            
            let attributedContent = NSMutableAttributedString(string: content)
            attributedContent.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: NSRange(location: 0, length: NSString.init(string: content).length))
            attributedContent.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], range: NSRange(location: 0, length: NSString.init(string: content).length))
            return Message(message: message, content: content, kind: .attributedText(attributedContent))
        } else {
            return message
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
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
                return UIFont.systemFont(ofSize: 16).capHeight * 2
            }
        default:
            break
        }
        // Display send date.
        if indexPath.section % 10 == 0 {
            return UIFont.boldSystemFont(ofSize: 16).capHeight * 2
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
        // bot chat
        if isDemo {
            didReceiveUserMessage()
        }
    }
}

//extension ChatViewController{
//    
//    fileprivate func messageInputBarCameraButtonSetup() {
//        let cameraItem = InputBarButtonItem(type: .system)
//        cameraItem.image = UIImage(systemName: "camera")
//        cameraItem.addTarget(
//            self,
//            action: #selector(cameraButtonPressed),
//            for: .primaryActionTriggered
//        )
//        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
//    }
//    
//    
//    private func uploadImage(_ image: UIImage, to channel: Chatroom, completion: @escaping (URL?) -> Void) {
//        guard let channelID = channel.id else {
//            completion(nil)
//            return
//        }
//        
//        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.UIImageJPEGRepresentation(compressionQuality: 0.4) else {
//            completion(nil)
//            return
//        }
//        
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//        
//        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
//        let imageRef = FirebaseConstants.chatroomStorage.child(channelID).child(imageName)
//        imageRef.putData(data, metadata: metadata) { metadata, _ in
//            guard metadata != nil else {
//                completion(nil)
//                return
//            }
//            // Async fetch the download URL.
//            imageRef.downloadURL { url, _ in
//                completion(url)
//            }
//        }
//    }
//    
//    private func sendPhoto(_ image: UIImage) {
//        isSendingPhoto = true
//        
//        uploadImage(image, to: chatroom) { [weak self] url in
//            guard let self = self, let url = url else { return }
//            self.isSendingPhoto = false
//            
//            let message = Message(user: self.user, imageURL: url)
//            self.save(message)
//            self.messagesCollectionView.scrollToLastItem()
//        }
//    }
//    
//    @objc
//    private func cameraButtonPressed(_ sender: InputBarButtonItem) {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .photoLibrary
//        present(picker, animated: true, completion: nil)
//    }
//    
//}
// MARK: - UIImagePickerControllerDelegate
/*
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
 */
