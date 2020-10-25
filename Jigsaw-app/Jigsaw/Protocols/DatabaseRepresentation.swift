//
//  DatabaseRepresentation.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

/// A protocol to serialize an object into Firebase's `[String: Any]` structure.
protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}
