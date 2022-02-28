//
//  User.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import Foundation

// 데이터 저장용
struct User {
    var uuid: String
    var email: String
    var nickName: String
}

// 디코딩용
struct UserData: Codable {
    var email: String
    var nickName: String
}
