//
//  AuthUserViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 1/18/24.
//

import UIKit
import FirebaseAuth
import JDStatusBarNotification
class AuthUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var otpDesc: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var verificationId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resendButton.isEnabled = false
        resendButton.layer.cornerRadius = 10
        resendButton.layer.borderWidth = 1
        resendButton.setTitleColor(.lightGray, for: .normal)
        submitButton.layer.cornerRadius = 10
        numberTextField.delegate = self
        otpTextField.delegate = self
        
    }


    @IBAction func submitPressed(_ sender: Any) {
        if otpLabel.isHidden {
            guard let phoneNumber = phoneTextField.text else {
                // Produce Error dialog!
                NotificationPresenter.shared.present("전화번호를 입력해주세요", includedStyle: .error)
                return
            }
            
            Auth.auth().languageCode = "ko"
            
            PhoneAuthProvider.provider()
                .verifyPhoneNumber("+82\(phoneNumber)", uiDelegate: nil) { verificationID, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.verificationId = verificationID
                    
                    DispatchQueue.main.async {
                        self.otpLabel.isHidden = false
                        self.otpTextField.isHidden = false
                        self.otpDesc.isHidden = false
                        self.phoneTextField.isEnabled = false
                        self.otpTextField.becomeFirstResponder()
                        self.submitButton.setTitle("인증번호 확인", for: .normal)
                        self.resendButton.isHidden = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5000)) {
                        self.resendButton.isEnabled = true
                        self.resendButton.setTitleColor(UIColor().hexStringToUIColor(hex: "#000000"), for: .normal)
                    }
                }
        } else {
            self.submitCode()
        }
        
        
        
    }
    
    func submitCode() {
        guard let code = self.otpTextField.text,
              let phoneNumber = self.phoneTextField.text else {
            NotificationPresenter.shared.present("인증번호를 입력해주세요", includedStyle: .error)
            //Show error dialog!
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationId, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                NotificationPresenter.shared.present(error.localizedDescription, includedStyle: .error)
                //Show error dialog!
                return
            }
            
            MyUserDefaults.saveString(with: "userPhoneNumber", value: phoneNumber)
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeTabBarViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                let navigationController = UINavigationController(rootViewController: homeTabBarViewController)
                navigationController.modalPresentationStyle = .fullScreen
                
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func resendOtp(_ sender: Any) {
        guard let phoneNumber = phoneTextField.text else {
            NotificationPresenter.shared.present("전화번호를 입력해주세요", includedStyle: .error)
      //      ErrorDialog.showErrorDialog(with: "전화번호를 입력해주세요", from: self)
            return
        }
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber("+82\(phoneNumber)", uiDelegate: nil) { verificationID, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                self.verificationId = verificationID
            }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDismiss() {
        self.view.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
}
