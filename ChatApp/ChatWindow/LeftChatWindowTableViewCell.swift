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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
