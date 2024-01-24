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
//            Manager.shared.setUserID(userID: userID)
            self.loadUserConfigs(userID: userID) {
                self.moveToNextScreen()
            }
        } else {
            self.generateUser()
        }
    }
    
    private func loadUserConfigs(userID: String, closure: @escaping () -> Void) {
        let params: Parameters = ["userID" : userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable2/get_user2.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: User2.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let user = response.value else { return }
                Manager2.shared.setUser(user: user)
                closure()
                
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
        
        let tempCategoryID = UUID().uuidString
        let manualCategoryID = UUID().uuidString
        let categoryIDs = [tempCategoryID, manualCategoryID]
        
        let params: Parameters = ["os" : "ios", 
                                  "userID" : userID,
                                  "tempCategoryID": tempCategoryID,
                                  "manualCategoryID": manualCategoryID,
                                  "categoryIDs": categoryIDs.joined(separator: ",")]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable2/create_product2.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                self.loadUserConfigs(userID: userID) {
                    self.showAuthDialog()
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func showAuthDialog() {
        let view = AuthDialogView.instantiateFromNib()
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: false, dismissOnActionTapped: true)
        malert.buttonsAxis = .vertical
        malert.buttonsSpace = 10
        malert.buttonsSideMargin = 20
        malert.buttonsBottomMargin = 20
        malert.cornerRadius = 10
        malert.separetorColor = .clear
        malert.animationType = .fadeIn
        malert.buttonsHeight = 50
        malert.presentDuration = 1.0
        
        let completeButton = MalertAction(title: "확인") {
            malert.dismiss(animated: true) {
                DispatchQueue.main.async {
                    let authVC = AuthUserViewController(nibName: "AuthUserViewController", bundle: Bundle.main)
                    authVC.modalPresentationStyle = .fullScreen
                    authVC.receiveItem(fromAuthDialog: true)
                    self.present(authVC, animated: true)
                }
            }
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#8851f5")
        completeButton.tintColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        
        let cancelButton = MalertAction(title: "다음에") {
            malert.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.showNextTimeDialog()
                }
            }
        }

        cancelButton.cornerRadius = 10
        cancelButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#e5e8f7")
        cancelButton.tintColor = UIColor().hexStringToUIColor(hex: "#9c9eaa")
        cancelButton.borderColor = UIColor().hexStringToUIColor(hex: "#e5e8f7")
        cancelButton.borderWidth = 1
        
        malert.addAction(completeButton)
        malert.addAction(cancelButton)
    
        DispatchQueue.main.async {
            self.present(malert, animated: true, completion: nil)
        }
    }
    
    func showNextTimeDialog() {
        let view = NextTimeDialogView.instantiateFromNib()
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: false, dismissOnActionTapped: true)
        malert.buttonsAxis = .vertical
        malert.buttonsSpace = 10
        malert.buttonsSideMargin = 20
        malert.buttonsBottomMargin = 20
        malert.cornerRadius = 10
        malert.separetorColor = .clear
        malert.animationType = .fadeIn
        malert.buttonsHeight = 50
        malert.presentDuration = 1.0
        
        let completeButton = MalertAction(title: "확인") {
            self.moveToNextScreen()
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#8851f5")
        completeButton.tintColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        
        malert.addAction(completeButton)
    
        DispatchQueue.main.async {
            self.present(malert, animated: true)
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
