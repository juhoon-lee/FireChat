//
//  ChatWindowTableViewCell.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit

class LeftChatWindowTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var leftTalkLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none // 클릭시 회색으로 되지 않음
        self.leftTalkLabel.clipsToBounds = true
        self.leftTalkLabel.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
