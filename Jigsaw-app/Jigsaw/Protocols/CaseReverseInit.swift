//
//  CaseReverseInit.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

protocol CaseReverseInit {
    static var mappingDict: [String: Self] { get }
    
    init?(label: String)
}
