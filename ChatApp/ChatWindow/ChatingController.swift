//
//  ChatingTableViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit
import Foundation

class ChatingController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var talks: [Talk] = [Talk(talk: "안녕하세요", uuid: "1"),Talk(talk: "네 안녕하세요", uuid: "2")]
    
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
        
        switch talks[indexPath.row].uuid {
        case "1":
            guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "LeftChatWindowTableViewCell", for: indexPath) as? LeftChatWindowTableViewCell else {return UITableViewCell()}
            cell.userNameLabel.text = talks[indexPath.row].uuid
            cell.leftTalkLabel.text = talks[indexPath.row].talk
            cell.backgroundColor = .red
            
            return cell
        case "2":
            guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "RightChatWindowTableViewCell", for: indexPath) as? RightChatWindowTableViewCell else {return UITableViewCell()}
            
            cell.userNameLabel.text = talks[indexPath.row].uuid
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
        
        self.view.endEditing(true)
        
        return false
    }
    
    // 텍스트필드 편집이 끝났을 때
//    func textFieldDidEndEditing(_ textField: UITextField) {
//    }
    
}
