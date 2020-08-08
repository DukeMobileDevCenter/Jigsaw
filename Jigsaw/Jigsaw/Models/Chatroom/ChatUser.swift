//
//  ChatUser.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
    var jigsawValue: Double
}
