//
//  AuthUserViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 1/18/24.
//

import UIKit
import FirebaseAuth
import JDStatusBarNotification
import FirebaseMessaging

class AuthUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var sendOtpButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var verificationId: String!
    var fromAuthDialog: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sendOtpButton.layer.cornerRadius = 10
        self.sendOtpButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#8851f5")
        self.submitButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#cecece")
        self.submitButton.isEnabled = false
        
        self.phoneTextField.delegate = self
        self.otpTextField.delegate = self
        
        self.otpTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        self.skipButton.isHidden = !self.fromAuthDialog
        
        if !self.fromAuthDialog {
            self.setupNavigationBar()
        }
    }
    
    func setupNavigationBar() {
        self.title = "본인 인증"
        navigationItem.backButtonTitle = " "
        self.view.changeStatusBarBgColor(bgColor: UIColor().hexStringToUIColor(hex: "#6200EE"))
        navigationController?.navigationBar.tintColor = UIColor.white
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            let barAppearence = UIBarButtonItemAppearance()
            barAppearence.normal.titleTextAttributes = [.foregroundColor: UIColor.yellow]
            appearance.buttonAppearance = barAppearence
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.standardAppearance = appearance
        }
    }
    
    func receiveItem(fromAuthDialog: Bool) {
        self.fromAuthDialog = fromAuthDialog
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = self.otpTextField.text, !text.isEmpty {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = true
                self.submitButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#8851f5")
            }
        } else {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = false
                self.submitButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#cecece")
            }
        }
    }

    @IBAction func sendOtpPressed(_ sender: UIButton) {
        guard let phoneNumber = self.phoneTextField.text,
            !phoneNumber.isEmpty else {
            NotificationPresenter.shared.present("전화번호를 입력해주세요", includedStyle: .error, duration: 3.0)
            return
        }
        
        Auth.auth().languageCode = "ko"
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber("+82\(phoneNumber)", uiDelegate: nil) { verificationID, error in
                if let error = error {
                    NotificationPresenter.shared.present(error.localizedDescription, includedStyle: .error, duration: 3.0)
                    return
                }
                
                self.verificationId = verificationID
                
                DispatchQueue.main.async {
                    self.otpTextField.isHidden = false
                    self.phoneTextField.isEnabled = false
                    self.otpTextField.becomeFirstResponder()
                    self.sendOtpButton.setTitle("인증번호 재전송", for: .normal)
                    self.sendOtpButton.isEnabled = false
                    self.sendOtpButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#cecece")
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5000)) {
                    self.sendOtpButton.isEnabled = true
                    self.sendOtpButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#8851f5")
                }
            }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        guard let code = self.otpTextField.text,
              let phoneNumber = self.phoneTextField.text,
              !code.isEmpty else {
            NotificationPresenter.shared.present("인증번호를 입력해주세요", includedStyle: .error)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationId, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                NotificationPresenter.shared.present(authError.localizedDescription, includedStyle: .error, duration: 2.0)
                return
            }
            
            MyUserDefaults.saveString(with: "userPhoneNumber", value: phoneNumber)
            
            NetworkManager.updateUserPhoneNumber(userPhoneNumber: phoneNumber) { response in
                switch response.result {
                case .success:
                    self.requestNotificationPermission(userPhoneNumber: phoneNumber)
                case .failure:
                    NotificationPresenter.shared.present(response.error?.localizedDescription ?? "FAIL", includedStyle: .error, duration: 2.0)
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        self.view.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func requestNotificationPermission(userPhoneNumber: String){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { value, _ in
            NetworkManager.updatePushNotification(pushEnabled: value) { response in
                switch response.result {
                case .success:
                    if self.fromAuthDialog {
                        Manager2.shared.user.userPhoneNumber = userPhoneNumber
                        Manager2.shared.user.pushEnabled = value
                        
                        if value {
                            Messaging.messaging().subscribe(toTopic: "myyou_pro_\(Manager2.shared.getUserPhoneNumber())")
                            print("SUBSCRIBED TO TOPIC SUCCESSFULLY")
                        }
                        
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let homeTabBarViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                            let navigationController = UINavigationController(rootViewController: homeTabBarViewController)
                            navigationController.modalPresentationStyle = .fullScreen
                            
                            self.present(navigationController, animated: true, completion: nil)
                        }
                    } else {
                        HomeViewController.reload {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                case .failure:
                    NotificationPresenter.shared.present(response.error?.localizedDescription ?? "FAIL", includedStyle: .error, duration: 2.0)
                }
            }
        })
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBarViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            let navigationController = UINavigationController(rootViewController: homeTabBarViewController)
            navigationController.modalPresentationStyle = .fullScreen
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
