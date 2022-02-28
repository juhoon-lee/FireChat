//
//  LoginViewController.swift
//  ChatApp
//
//  Created by 이주훈 on 2022/02/24.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.layer.cornerRadius = stackView.frame.height / 2
        logoContainer.layer.cornerRadius = stackView.frame.height / 2
    }
    
    @IBAction func tapLoginButton(_ sender: UIButton) {
       
        // 구글 인증
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) {[weak self]  user, error in
            guard let self = self else {return}
            guard error == nil else { return }
            
            // 인증을 해도 계정은 따로 등록을 해주어야 한다.
            // 구글 인증 토큰 받아서 -> 사용자 정보 토큰 생성 -> 파이어베이스 인증에 등록
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            // 사용자 정보 등록
            Auth.auth().signIn(with: credential) { _, _ in
                // 사용자 등록 후에 처리할 코드
            }
            
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NickNameViewController") as? NickNameViewController else { return }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
