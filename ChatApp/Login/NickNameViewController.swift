//
//  NickNameViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/27.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NickNameViewController: UIViewController {
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var setNickNameButton: UIButton!
    
//    var ref: DatabaseReference!
    var ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        nickNameTextField.delegate = self
        setNickNameButton.layer.cornerRadius = setNickNameButton.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nickNameTextField.text = Auth.auth().currentUser?.displayName
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func tapNicknameButton(_ sender: UIButton) {
        setNickName()
    }
    
    func setNickName() {
        guard let user = Auth.auth().currentUser else {return}
        guard let nickName = nickNameTextField.text else {
            nickNameTextField.placeholder = "채워주세요~"
            return
        }
        guard let changeRequrest = Auth.auth().currentUser?.createProfileChangeRequest() else {return}
        changeRequrest.displayName = nickName
        let uid = user.uid
        let email = user.email
        // 데이터베이스에 사용자 추가 코드 작성.
        self.ref.child("users/\(String(describing: uid))").setValue(["nickName": nickName, "email":email])
        
        
        // tapBarController로 전환.
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "LoginTapBarController")
        vcName?.modalPresentationStyle = .fullScreen
        vcName?.modalTransitionStyle = .flipHorizontal // 전환 애니메이션(fullScreen일 때에만 가능한듯)
        self.present(vcName!, animated: true, completion: nil)
    }
}

extension NickNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setNickName()
        return true
    }
}
