//
//  MyChatViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class MyChatViewController: UIViewController {
    @IBOutlet weak var myChatTableView: UITableView!
    
    var users: [User] = []
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let MyChatTableViewCell = UINib(nibName: "MyChatTableViewCell", bundle: Bundle.main)
        myChatTableView.register(MyChatTableViewCell, forCellReuseIdentifier: "MyChatTableViewCell")
        
        myChatTableView.dataSource = self
        myChatTableView.delegate = self
        
        loadUsers()
    }
    
    func loadUsers() {
        
        guard let myUID = Auth.auth().currentUser?.uid else {return}
        ref.child("chats/\(myUID)").observe(DataEventType.value) { snapshot in
            
            guard let snapData = snapshot.value as? [String: Any] else {return}
            
            let keys = snapData.keys
            
            self.checkNickName(uid: Array(keys))
        }
    }
    
    func checkNickName(uid: [String]) {
        
        ref.child("users").observe(DataEventType.value) { snapshot in
            guard let snapData = snapshot.value as? [String: Any] else {return}
            
            let jsonData = try! JSONSerialization.data(withJSONObject: snapData, options: .prettyPrinted)
            let data = try! JSONDecoder().decode([String: UserData].self, from: jsonData )
            
            var tempUsers: [User] = []
            
            for i in 0..<uid.count {
                tempUsers.append(User(uuid: uid[i], email: data[uid[i]]?.email ?? "none", nickName: data[uid[i]]?.nickName ?? "닉네임 없음"))
            }
            self.users = tempUsers
            
            DispatchQueue.main.async {
                self.myChatTableView.reloadData()
            }
            
        }
    }
    
    @IBAction func tapLogoutButton(_ sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance.signOut()
        
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        vcName?.modalPresentationStyle = .fullScreen
        vcName?.modalTransitionStyle = .flipHorizontal
        // 전환 애니메이션(fullScreen일 때에만 가능한듯)
        self.present(vcName!, animated: true, completion: nil)
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let chatController = self.storyboard?.instantiateViewController(withIdentifier: "ChatingController") as? ChatingController else {return}
        
        chatController.myUID = Auth.auth().currentUser?.uid
        chatController.opponentUID = users[indexPath.row].uuid
        
        self.navigationController?.pushViewController(chatController, animated: true)
    }
}
