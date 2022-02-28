//
//  User.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import Foundation


struct User: Codable {
    var uuid: String
    var myChat: Bool
    var userData: UserData
}

struct UserData: Codable {
    var email: String
    var nickName: String
}
