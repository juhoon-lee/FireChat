//
//  ChatingTableViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ChatingController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendStackView: UIStackView!
    
    var talks: [Talk] = []
    
    var ref = Database.database().reference()
    
    // 나와 상대의 uid
    var myUID: String?
    var opponentUID: String?
    // 나와 상대의 닉네임
    var myNIckName: String?
    var oppentNickName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Settings()
        
        // tableview의 터치 이벤트 추가
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        
        //        navigationController?.isNavigationBarHidden = false // 네비게이션 바 숨기기
        navigationItem.title = oppentNickName
        
        // 키보드가 나올때 View를 올려버리는 것을 observing
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardHideNotification(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // 터치가 발생할때 핸들러 캐치
    @objc func handleTap(sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    // 키보드 올라가는 이벤트
    @objc func keyboardNotification(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.sendStackView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 35)
        }
    }
    
    // 키보드 내려가는 이벤트
    @objc func keyboardHideNotification(notification: NSNotification) {
   
        self.sendStackView.transform = CGAffineTransform(translationX: 0, y: 0 )
    }
    
    func Settings() {
        chatTableView.dataSource = self
        chatTableView.delegate = self
        textField.delegate = self // textFiled에 delegate 구현
        
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 30
        
        // 상대방 대화 cell 등록
        let leftCell = UINib(nibName: "LeftChatWindowTableViewCell", bundle: Bundle.main)
        chatTableView.register(leftCell, forCellReuseIdentifier: "LeftChatWindowTableViewCell")
        
        // 나의 대화 cell 등록
        let rightCell = UINib(nibName: "RightChatWindowTableViewCell", bundle: Bundle.main)
        chatTableView.register(rightCell, forCellReuseIdentifier: "RightChatWindowTableViewCell")
        
        // 텍스트 필드와 버튼 보이게
        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 3
        sendButton.layer.borderColor = UIColor.black.cgColor
        
        guard let myUID = myUID, let opponentUID = opponentUID else {return}
        
        
        // 닉네임 가져오기
        ref.child("users/\(myUID)/nickName").observe(DataEventType.value) { snapshot in
            self.myNIckName  = snapshot.value as? String ?? "Unknown";
        }
        
        ref.child("users/\(opponentUID)/nickName").observe(DataEventType.value) { snapshot in
            self.oppentNickName  = snapshot.value as? String ?? "Unknown";
            self.navigationItem.title = self.oppentNickName
        }
        
        // 대화 옵저버 달기
        
        ref.child("chats/\(myUID)/\(opponentUID)").observe(DataEventType.value) { snapshot in
            guard let snapData = snapshot.value as? [String: Any] else {return}
            
            let jsonData = try! JSONSerialization.data(withJSONObject: snapData, options: .prettyPrinted)
            let data = try! JSONDecoder().decode([String: Talk].self, from: jsonData )
            
            let sortedData = data.sorted{ $0.value.time < $1.value.time}
            
            var tempTalk: [Talk] = []
            for i in 0..<sortedData.count {
                tempTalk.append(Talk(talk: sortedData[i].value.talk, uuid: sortedData[i].value.uuid, time: sortedData[i].value.time))
                self.talks = tempTalk
            }
            
            // 데이터 reload + 마지막으로 스크롤
            let endindex = IndexPath(row: self.talks.count - 1, section: 0)
            
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
                self.chatTableView.scrollToRow(at: endindex, at: .bottom, animated: false)
            }
            
        }
        
    }
    
    // 데이터베이스에 채팅 추가
    func sendData() {
        guard let myUID = myUID, let opponentUID = opponentUID else {return}
        if !(textField.text?.isEmpty ?? true) {
            let text = textField.text
            
            // firebase Key 에는 "."이 못 들어간다..
            let time = String(Date().timeIntervalSince1970)
            self.ref.child("chats/\(myUID)/\(opponentUID)/\(UUID().uuidString)").setValue(
                ["talk":text, "uuid":myUID, "time": time]
            )
            self.ref.child("chats/\(opponentUID)/\(myUID)/\(UUID().uuidString)").setValue(
                ["talk":text, "uuid":myUID, "time": time]
            )
            textField.text = ""
            self.view.endEditing(true)
        }
    }
    
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        sendData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

// tableView cell 편집을 해볼까
extension ChatingController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let meUID = myUID, let opponentUID = opponentUID else {return UITableViewCell()}
        
        switch talks[indexPath.row].uuid {
        case opponentUID:
            guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "LeftChatWindowTableViewCell", for: indexPath) as? LeftChatWindowTableViewCell else {return UITableViewCell()}
            cell.userNameLabel.text = oppentNickName
            cell.leftTalkLabel.text = talks[indexPath.row].talk
//            cell.backgroundColor = .red
            
            return cell
        case meUID:
            guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "RightChatWindowTableViewCell", for: indexPath) as? RightChatWindowTableViewCell else {return UITableViewCell()}
            
            cell.userNameLabel.text = myNIckName
            cell.rightTalkLabel.text = talks[indexPath.row].talk
//            cell.backgroundColor = .blue
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ChatingController: UITableViewDelegate {
    
}


// textFiled Delagate 채택
extension ChatingController: UITextViewDelegate {
    
    // 텍스트필드 편집이 시작되었을 때
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //    }
    
    // 리턴버튼이 눌렸을 때
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // 데이터베이스에 채팅 내용 구현
        sendData()
        return false
    }
}
