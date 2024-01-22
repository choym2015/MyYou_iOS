//
//  ViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/22/23.
//
import UIKit
import FirebaseFirestore
import FirebaseFirestoreInternal
import JDStatusBarNotification
import Malert
import Alamofire

class ViewController: UIViewController {
    
    static let LOAD_CONFIGURATIONS_URL = "https://chopas.com/smartappbook/myyou/configurationTable/get_configurations.php"

    let userDefaults = UserDefaults.standard
    let database = Firestore.firestore()
    var userID: String!
    
    let blackView = UIView()
    var popupView = UIView()
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if Reachability.isConnectedToNetwork() {
            self.loadConfigurations()
        } else {
            NotificationPresenter.shared.present("인터넷 연결을 확인해주세요", includedStyle: .error)
        }
    }
    
    func loadConfigurations() {
        guard let url = URL(string: ViewController.LOAD_CONFIGURATIONS_URL) else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let data = data,
                  let configuration = try? JSONDecoder().decode(Configuration.self, from: data) else {
                return
            }
            
            self.checkConfiguration(configuration: configuration)
        })
        
        task.resume()
    }
    
    private func checkConfiguration(configuration: Configuration) {
        if configuration.bomb == "true" {
            self.showBombAlert()
            return
        }
        
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        
        DispatchQueue.main.async {
            self.versionLabel.text = "v \(appVersion)"
        }
        
        guard configuration.version == appVersion else {
            self.showUpdate(isHardUpdateRequired: configuration.hardUpdateRequired == "true" ? true : false)
            return
        }
        
        if let userID = self.userDefaults.string(forKey: "userID") {
            Manager.shared.setUserID(userID: userID)
            self.loadUserConfigs()
        } else {
            self.generateUser()
        }
    }
    
    private func loadUserConfigs() {
        let userID = Manager.shared.getUserID()
        let params: Parameters = ["userID" : userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable/get_user.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: User.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let user = response.value else { return }
                
                user.updateManager()
                //self.showAuthDialog()
                //self.moveToNextScreen()
                if self.userDefaults.value(forKey: "userPhoneNumber") != nil {
                    print("user has put in number or chose next time.")
                    self.moveToNextScreen()
                }
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func generateUser() {
        let userID = UUID().uuidString
        self.userID = userID
        self.userDefaults.setValue(self.userID, forKey: "userID")
        Manager.shared.setUserID(userID: self.userID)
        
        let params: Parameters = ["os" : "ios", "userID" : userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable/create_product.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                self.showAuthDialog()
                self.loadUserConfigs()
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func showAuthDialog() {
        //show dialog
        popupView = {
            let view = AuthDialogView.instantiateFromNib()
            view.titleText.text = "다른 사용자에게 동영상을 받으시려면 본인인증이\n필요합니다."
            view.confirmButton.layer.cornerRadius = 10
            view.confirmButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
            view.confirmButton.addTarget(self, action: #selector(pressedConfirm), for: .touchUpInside)
            view.skipButton.layer.cornerRadius = 10
            view.skipButton.addTarget(self, action: #selector(pressedSkip), for: .touchUpInside)
            
            return view
        }()
        
        if let window = UIApplication.shared.keyWindow {
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(self.blackView)
            window.addSubview(popupView)
            
            let height: CGFloat = window.frame.height*5/6
            let y = window.frame.height - height
            popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            //self.blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.popupView.frame = CGRect(x: 0, y: y, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func pressedConfirm() {
        DispatchQueue.main.async {
            let auth = AuthUserViewController(nibName: "AuthUserViewController", bundle: Bundle.main)
            
            self.presentedViewController?.present(auth, animated: true)
            self.present(auth, animated: true)
        }
    }
    
    @objc func pressedSkip() {
        //create nextTimeDialog
        let alert = UIAlertController(title: "마이유", message: "본인인증은 설정 -> 본인인증 하기에서 진행할 수 있습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in
            self.userDefaults.set("010-next-time", forKey: "userPhoneNumber")
            self.moveToNextScreen()
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func moveToNextScreen() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBarViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            let navigationController = UINavigationController(rootViewController: homeTabBarViewController)
            navigationController.modalPresentationStyle = .fullScreen
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func showBombAlert() {
        DispatchQueue.main.async {
            //show bomb alert here
        }
    }
    
    private func showUpdate(isHardUpdateRequired: Bool) {
        DispatchQueue.main.async {
            //show bomb alert here
        }
    }
}
