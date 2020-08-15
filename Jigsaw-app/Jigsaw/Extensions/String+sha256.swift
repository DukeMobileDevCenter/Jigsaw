//
//  String+sha256.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/12/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    var sha256: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    var gravatarURL: URL {
        let gravatarHash = self.sha256
        let endIndex = gravatarHash.index(gravatarHash.startIndex, offsetBy: 32)
        let gravatarURL = URL(string: "https://www.gravatar.com/avatar/\(gravatarHash[..<endIndex])?d=wavatar")!
        return gravatarURL
    }
}
