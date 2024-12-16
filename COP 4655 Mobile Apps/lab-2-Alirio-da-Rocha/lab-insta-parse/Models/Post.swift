//
//  Post.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/29/22.
//

import ParseSwift
import Foundation

// TODO: Pt 1 - Import Parse Swift


// TODO: Pt 1 - Create Post Parse Object model
//

struct Post: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var caption: String?
    var user: User?
    var imageFile: ParseFile?
}
