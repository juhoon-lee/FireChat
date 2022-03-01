//
//  RightChatWindowTableViewCell.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit

class RightChatWindowTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var rightTalkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none // 클릭시 회색으로 되지 않음
        self.rightTalkLabel.clipsToBounds = true
        self.rightTalkLabel.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
