//
//  UserListViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class UserListViewController: UIViewController {
    
    var users: [User] = []
    
    @IBOutlet weak var UserTableView: UITableView!
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserTableView.delegate = self
        UserTableView.dataSource = self
        
        // nib 등록 잊지 말자 삽질 너무 많이 했다..
        let userCell = UINib(nibName: "UserListTableViewCell", bundle: Bundle.main)
        UserTableView.register(userCell, forCellReuseIdentifier: "UserListTableViewCell")
        
        // 네비게이션 바 숨기기
        // navigationController?.isNavigationBarHidden = true
        
        // 유저 리스트 불러오기
        loadUsers()
    }
    
    func loadUsers() {
        
        ref.child("users").observe(DataEventType.value) { snapshot in

//            print("스냅샷\(snapshot.value)")
            guard let snapData = snapshot.value as? [String: Any] else {return}
//            print("스냅샷 데이터 \(snapData)")
            
            let data = try! JSONSerialization.data(withJSONObject: snapData, options: .prettyPrinted)
            let jsonData = try! JSONDecoder().decode([String: UserData].self, from: data )
//            print(jsonData.keys)
//            print(jsonData.values)
            
            // 유저 닉네임 순으로 정렬
            let sortedData = jsonData.sorted{ $0.value.nickName > $1.value.nickName }
            
            print(sortedData)
            for i in 0..<sortedData.count {
                let user = User(uuid: sortedData[i].key,
                                email: sortedData[i].value.email,
                                nickName: sortedData[i].value.nickName )

                // 목록에 자신을 제외하고 표시하기 위함.
                if user.uuid != Auth.auth().currentUser?.uid {
                    self.users.append(user)
                }
            }
            
            
            DispatchQueue.main.async {
                self.UserTableView.reloadData()
            }
//            users = jsonData
        }
    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = UserTableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath) as? UserListTableViewCell else {
            return  UITableViewCell()}
        
        let user = users[indexPath.row]
        cell.setUp(user: user)
        
        return cell
    }
    
    // cell의 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let chatController = self.storyboard?.instantiateViewController(withIdentifier: "ChatingController")  else {return}
        
        self.navigationController?.pushViewController(chatController, animated: true)
    }
}
