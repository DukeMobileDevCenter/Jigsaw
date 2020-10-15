//
//  Message.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MessageKit

struct Message: MessageType {
    let id: String?
    let content: String
    let sentDate: Date
    let senderJigsawValue: Double
    
    let downloadURL: URL?
    
    let kind: MessageKind
    private let user: ChatUser
    
    var sender: SenderType {
        return user
    }
    
    var data: MessageKind {
        if let downloadURL = downloadURL {
            return .photo(ImageMediaItem(url: downloadURL, image: nil))
        } else {
            return .text(content)
        }
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    init(user: User, content: String) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.content = content
        self.sentDate = Date()
        self.id = nil
        self.kind = .text(content)
        self.downloadURL = nil
        self.senderJigsawValue = Profiles.jigsawValue
    }
    
    /// An initializer to replace a text message's content with a new string.
    ///
    /// - Parameters:
    ///   - message: The original message.
    ///   - content: The new content string to replace the old one.
    init(message: Message, content: String) {
        self.user = message.user
        // The content string is the control message.
        self.content = message.content
        self.sentDate = message.sentDate
        self.id = message.id
        // The kind enum case is the emoji string.
        self.kind = .text(content)
        self.downloadURL = message.downloadURL
        self.senderJigsawValue = message.senderJigsawValue
    }
    
    init(user: User, controlMetaMessage: ControlMetaMessage) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.content = controlMetaMessage.rawValue
        self.sentDate = Date()
        self.id = nil
        self.kind = .text(controlMetaMessage.rawValue)
        self.downloadURL = nil
        self.senderJigsawValue = Profiles.jigsawValue
    }
    
    init(user: User, imageURL: URL) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.content = ""
        self.sentDate = Date()
        self.id = nil
        self.kind = .photo(ImageMediaItem(url: imageURL, image: nil))
        self.downloadURL = imageURL
        self.senderJigsawValue = Profiles.jigsawValue
    }
    
    init?(document: QueryDocumentSnapshot) {
        let docData = document.data()
        id = document.documentID
        
        guard let docSenderID = docData["senderID"] as? String,
            let docSenderName = docData["senderName"] as? String,
            let jigsawValue = docData["senderJigsawValue"] as? Double,
            let docSentDate = docData["created"] as? Timestamp else { return nil }
        
        self.sentDate = docSentDate.dateValue()
        self.user = ChatUser(senderId: docSenderID, displayName: docSenderName, jigsawValue: jigsawValue)
        self.senderJigsawValue = jigsawValue
        
        if let text = docData["content"] as? String {
            downloadURL = nil
            self.content = text
            self.kind = .text(text)
        } else if let urlString = docData["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
            self.kind = .photo(ImageMediaItem(url: url, image: nil))
        } else {
            return nil
        }
    }
}

extension Message: DatabaseRepresentation {
    var representation: [String: Any] {
        var rep: [String: Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "senderJigsawValue": senderJigsawValue
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
    }
}

extension Message: Comparable {
    // Compare equal by id.
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    // Compare smaller than by date.
    static func < (lhs: Message, rhs: Message) -> Bool {
        lhs.sentDate < rhs.sentDate
    }
}

private struct ImageMediaItem: MediaItem {
    let url: URL?
    let image: UIImage?
    let size: CGSize
    let placeholderImage: UIImage

    init(url: URL, image: UIImage?) {
        self.url = url
        self.image = image
        self.size = CGSize(width: 240, height: 160)
        self.placeholderImage = UIImage(named: "placeholder")!
    }
}

/// A enum to leverage text message to send metadata info, such as user joined or left the chatroom.
enum ControlMetaMessage: String {
    case join = "****join****"
    case leave = "****leave****"
    
    var label: String {
        switch self {
        case .join:
            return "joined"
        case .leave:
            return "left"
        }
    }
}
