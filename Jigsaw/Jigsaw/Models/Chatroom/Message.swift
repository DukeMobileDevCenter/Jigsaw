//
//  Message.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import MessageKit

struct Message: MessageType {
    let id: String?
    let content: String
    let sentDate: Date
    var kind: MessageKind
    var sender: SenderType {
        return user
    }
    
    var user: ChatUser
    
    var data: MessageKind {
        if let image = image {
            return .photo(image)
        } else {
            return .text(content)
        }
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var image: UIImage?
    var downloadURL: URL?
    
    init(user: User, content: String) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.content = content
        self.sentDate = Date()
        self.id = nil
        self.kind = .text(content)
    }
    
    init(user: User, image: UIImage) {
        self.user = ChatUser(senderId: user.uid, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
        self.image = image
        self.content = ""
        self.sentDate = Date()
        self.id = nil
        self.kind = .photo(image)
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Date,
            let senderID = data["senderID"] as? String,
            let senderName = data["senderName"] as? String,
            let jigsawValue = data["jigsawValue"] as? Double else {
                return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate
        self.user = ChatUser(senderId: senderID, displayName: senderName, jigsawValue: jigsawValue)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
            self.kind = .text(content)
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
            self.kind = .photo(UIImage())
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
            "senderName": sender.displayName
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
    // Equal by id.
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    // Compare by date.
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

extension UIImage: MediaItem {
    public var url: URL? {
        return nil
    }
    
    public var image: UIImage? {
        return self
    }
    
    public var placeholderImage: UIImage {
        return self
    }
}
