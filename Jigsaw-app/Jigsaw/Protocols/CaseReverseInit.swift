//
//  CaseReverseInit.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

/// A protocol that allows initializing an enum from its label string values,
/// given that they are 1-to-1 mapping.
protocol CaseReverseInit {
    /// The reverse mapping dictionary that maps a string to a enum case.
    static var mappingDict: [String: Self] { get }
    
    init?(label: String)
}
