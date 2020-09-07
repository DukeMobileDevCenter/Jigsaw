//
//  Message.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MessageKit

struct Message: MessageType {
    let id: String?
    let content: String
    let sentDate: Date
    let senderJigsawValue: Double
    
    var kind: MessageKind
    var sender: SenderType {
        return user
    }
    
    var user: ChatUser
    
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
    
    var downloadURL: URL?
    
    init(user: User, content: String) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.content = content
        self.sentDate = Date()
        self.id = nil
        self.kind = .text(content)
        self.senderJigsawValue = Profiles.jigsawValue
    }
    
    init(user: User, imageURL: URL) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.content = ""
        self.sentDate = Date()
        self.id = nil
        self.kind = .photo(ImageMediaItem(url: imageURL, image: nil))
        self.senderJigsawValue = Profiles.jigsawValue
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        id = document.documentID
        
        guard let docSenderID = data["senderID"] as? String,
            let docSenderName = data["senderName"] as? String,
            let jigsawValue = data["senderJigsawValue"] as? Double,
            let docSentDate = data["created"] as? Timestamp else { return nil }
        
        self.sentDate = docSentDate.dateValue()
        self.user = ChatUser(senderId: docSenderID, displayName: docSenderName, jigsawValue: jigsawValue)
        self.senderJigsawValue = jigsawValue
        
        if let text = data["content"] as? String {
            self.content = text
            downloadURL = nil
            self.kind = .text(text)
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
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
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(url: URL, image: UIImage?) {
        self.url = url
        self.image = image
        self.size = CGSize(width: 240, height: 160)
        self.placeholderImage = UIImage(named: "placeholder")!
    }
}
