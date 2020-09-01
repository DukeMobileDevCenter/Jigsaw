//
//  String+sha256.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/12/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    var sha256: String {
        let data = Data(self.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// The md5 string of a data.
    /// - Note: Refer to [CryptoKit](https://developer.apple.com/documentation/cryptokit).
    var md5: String {
        let data = Data(self.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var wavatarURL: URL {
        let gravatarHash = self.sha256
        let endIndex = gravatarHash.index(gravatarHash.startIndex, offsetBy: 32)
        let gravatarURL = URL(string: "https://www.gravatar.com/avatar/\(gravatarHash[..<endIndex])?d=wavatar")!
        return gravatarURL
    }
    
    /// The official implementation of Gravatar request.
    /// - Note: Refer to [Gravatar Reference](http://en.gravatar.com/site/implement/images/).
    var gravatarEmailURL: URL {
        URL(string: "https://www.gravatar.com/avatar/\(self.md5)")!
    }
}
