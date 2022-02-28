//
//  MyChatViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit

class MyChatViewController: UIViewController {
    @IBOutlet weak var myChatTableView: UITableView!
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let MyChatTableViewCell = UINib(nibName: "MyChatTableViewCell", bundle: Bundle.main)
        myChatTableView.register(MyChatTableViewCell, forCellReuseIdentifier: "MyChatTableViewCell")
        
        myChatTableView.dataSource = self
        myChatTableView.delegate = self
        
    }
}

extension MyChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = myChatTableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell", for: indexPath) as? MyChatTableViewCell else {return UITableViewCell()}
        
        cell.setUp(user: users[indexPath.row])
        
        return cell
    }
    
    
}

extension MyChatViewController: UITableViewDelegate {
    
}
