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
import Alamofire

class ViewController: UIViewController {
    
    static let LOAD_CONFIGURATIONS_URL = "https://chopas.com/smartappbook/myyou/configurationTable/get_configurations.php"

    let userDefaults = UserDefaults.standard
    let database = Firestore.firestore()
    var userID: String!
    
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
                self.moveToNextScreen()
                
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
                self.loadUserConfigs()
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
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
