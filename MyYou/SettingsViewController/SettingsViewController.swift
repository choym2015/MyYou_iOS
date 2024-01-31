//
//  SettingsViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import UIKit
import Malert
import JDStatusBarNotification

class SettingsViewController: UIViewController {
    @IBOutlet weak var authBackView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var proBackView: UIView!
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var pushLabel: UILabel!
    @IBOutlet weak var appAgreeLabel: UILabel!
    @IBOutlet weak var pushLabelSwitch: UISwitch!
    @IBOutlet weak var playNextSwitch: UISwitch!
    @IBOutlet weak var thumbnailSwitch: UISwitch!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
            
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    func setupUI() {
        self.authBackView.layer.borderColor = UIColor.lightGray.cgColor
        self.authBackView.layer.borderWidth = 1
        self.authBackView.layer.cornerRadius = 3
        self.proBackView.layer.cornerRadius = 3
        self.playNextSwitch.onTintColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        self.pushLabelSwitch.onTintColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        self.thumbnailSwitch.onTintColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        self.backgroundView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        self.addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            if Manager2.shared.user.userPhoneNumber.isEmpty {
                self.pushLabelSwitch.isEnabled = false
            } else {
                self.pushLabelSwitch.isEnabled = true
                self.pushLabelSwitch.isOn = Manager2.shared.user.pushEnabled
                self.registerLabel.text = "  본인 인증 완료"
                self.registerLabel.isUserInteractionEnabled = false
                self.registerButton.isHidden = true
            }
            
            self.setupSubscriptionUI()
            self.thumbnailSwitch.isOn = Manager2.shared.user.thumbnail
            self.playNextSwitch.isOn = Manager2.shared.user.playNext
        }
    }
    
    func setupSubscriptionUI() {
        if Manager2.shared.user.subscription == "pro" {
            self.proLabel.text = "마이유 프로 구독중"
            self.proLabel.isUserInteractionEnabled = false
            self.proButton.isHidden = true
        } else if Manager2.shared.user.subscription == "premium" {
            self.proLabel.text = "마이유 프리미엄 구독중"
            self.proLabel.isUserInteractionEnabled = false
            self.proButton.isHidden = true
        }
    }
    
    func addGestures() {
        let registerButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.registerButtonPressed(_:)))
        self.registerLabel.addGestureRecognizer(registerButtonTap)
        
        let repeatButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.repeatButtonPressed(_:)))
        self.repeatLabel.addGestureRecognizer(repeatButtonTap)
        
        let appAgreeButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.appAgreeButtonPressed(_:)))
        self.appAgreeLabel.addGestureRecognizer(appAgreeButtonTap)
        
        let proButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.proButtonPressed(_:)))
        self.proLabel.addGestureRecognizer(proButtonTap)
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let authVC = AuthUserViewController(nibName: "AuthUserViewController", bundle: Bundle.main)
            authVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(authVC, animated: true)
        }
    }
    
    @IBAction func thumbnailSwitchChanged(_ sender: UISwitch) {
        self.updateThumbnail(thumbnail: sender.isOn)
    }
    
    @IBAction func playNextSwitchChanged(_ sender: UISwitch) {
        self.updatePlayNext(playNext: sender.isOn)
    }
    
    @IBAction func repeatButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let repeatVC = RepeatViewController(nibName: "RepeatViewController", bundle: Bundle.main)
            self.present(repeatVC, animated: true)            
        }
    }
    
    @IBAction func proButtonPressed(_ sender: UIButton) {
        self.updatePro(subscription: "pro")
    }
    
    @IBAction func pushSwitchChanged(_ sender: UISwitch) {
//        self.updatePushEnabled(pushEnabled: sender.isOn)
        NetworkManager.updatePushNotification(pushEnabled: sender.isOn) { response in
            switch response.result {
            case .success:
                Manager2.shared.user.pushEnabled = sender.isOn
            case .failure(let error):
                NotificationPresenter.shared.present(error.localizedDescription, includedStyle: .error, duration: 2.0)
            }
        }
    }
    
    @IBAction func appAgreeButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let appAgreeVC = AppAgreeViewController(nibName: "AppAgreeViewController", bundle: Bundle.main)
            self.present(appAgreeVC, animated: true)
        }
    }
}
