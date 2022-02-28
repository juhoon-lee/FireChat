//
//  MyChatTableViewCell.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit

class MyChatTableViewCell: UITableViewCell {
    @IBOutlet weak var nickNameLabel: UILabel!
    
    func setUp(user: User) {
//        nickNameLabel.text = user.nickName
        
        self.accessoryType = .disclosureIndicator // 오른쪽 화살표
        self.selectionStyle = .none // 클릭시 회색으로 되지 않음
        
    }
    
}
