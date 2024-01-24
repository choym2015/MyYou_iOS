//
//  SettingsViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import UIKit
import Malert
class SettingsViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
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
        self.backgroundView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        DispatchQueue.main.async {
            if Manager2.shared.user.userPhoneNumber.isEmpty {
                self.pushLabelSwitch.isEnabled = false
            } else {
                self.pushLabelSwitch.isEnabled = true
                self.pushLabelSwitch.isOn = Manager2.shared.user.pushEnabled
                self.registerLabel.text = "본인 인증 완료"
                self.registerLabel.isUserInteractionEnabled = false
                self.registerButton.isHidden = true
            }
            
            self.setupSubscriptionUI()
            self.thumbnailSwitch.isOn = Manager2.shared.user.thumbnail
            self.playNextSwitch.isOn = Manager2.shared.user.playNext
        }
        
        self.addGestures()
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
            self.present(authVC, animated: true)
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
        self.updatePushEnabled(pushEnabled: sender.isOn)
    }
    
    @IBAction func appAgreeButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let appAgreeVC = AppAgreeViewController(nibName: "AppAgreeViewController", bundle: Bundle.main)
            self.present(appAgreeVC, animated: true)
        }
    }
}
