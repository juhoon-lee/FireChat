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
        
        //        navigationController?.isNavigationBarHidden = false // 네비게이션 바 숨기기
        navigationItem.title = "대화방 이름" // TODO 상대방 닉네임 설정할 예정
        
        // 키보드가 나올때 View를 올려버리는 것을 observing
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    
    // 키보드 올라가는 이벤트
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        if endFrameY >= UIScreen.main.bounds.size.height {
            self.view?.frame.origin.y = 0.0
        } else {
            self.view?.frame.origin.y -= endFrame?.size.height ?? 0.0
        }
        
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
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
        
        
        guard let myUID = myUID, let opponentUID = opponentUID else {return}
        
                
        // 닉네임 가져오기
        ref.child("users/\(myUID)/nickName").observe(DataEventType.value) { snapshot in
            self.myNIckName  = snapshot.value as? String ?? "Unknown";
        }
        
        ref.child("users/\(opponentUID)/nickName").observe(DataEventType.value) { snapshot in
            self.oppentNickName  = snapshot.value as? String ?? "Unknown";
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
            
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
            }
        }
        
        
        
    }
    
    // 데이터베이스에 채팅 추가
    func sendData() {
        guard let myUID = myUID, let opponentUID = opponentUID else {return}
        if textField.text != nil {
            let text = textField.text
            
            // firebase Key 에는 .이 못 들어간다..
            let time = String(Date().timeIntervalSince1970)
            self.ref.child("chats/\(myUID)/\(opponentUID)/\(UUID().uuidString)").setValue(
                ["talk":text, "uuid":myUID, "time": time]
            )
            self.ref.child("chats/\(opponentUID)/\(myUID)/\(UUID().uuidString)").setValue(
                ["talk":text, "uuid":myUID, "time": time]
            )
            textField.text = ""
        }
    }
    
    deinit {
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
            cell.backgroundColor = .red
            
            return cell
        case meUID:
            guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "RightChatWindowTableViewCell", for: indexPath) as? RightChatWindowTableViewCell else {return UITableViewCell()}
            
            cell.userNameLabel.text = myNIckName
            cell.rightTalkLabel.text = talks[indexPath.row].talk
            cell.backgroundColor = .blue
            
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
        self.view.endEditing(true)
        return false
    }
    
    // 텍스트필드 편집이 끝났을 때
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 데이터베이스에 채팅 내용 구현
        sendData()
    }
    
}
