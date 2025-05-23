//
//  FriendModel.swift
//  ALP-MAD
//
//  Created by student on 23/05/25.
//

import Foundation
// FriendModel.swift

import Foundation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let email: String
}
