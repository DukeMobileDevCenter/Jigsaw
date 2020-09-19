//
//  ChatUser.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import MessageKit

struct ChatUser: SenderType, Equatable {
    /// The ID, which is the same ID as the account and player ID.
    var senderId: String
    /// The nickname displayed in a chatroom. Now default to "unknown".
    var displayName: String
    /// The player's Jigsaw value, which may be fun to see as a color?
    var jigsawValue: Double
}
