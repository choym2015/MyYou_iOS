//
//  ViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/22/23.
//
import UIKit
import FirebaseFirestore
import FirebaseFirestoreInternal

class ViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    let database = Firestore.firestore()
    var userID: String!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateVersion()
        
        Manager.shared.setDB(db: database)
        
        if let userID = self.userDefaults.string(forKey: "userID") {
            self.userID = userID
            Manager.shared.setUserID(userID: userID)
            self.loadConfigurations()
        } else {
            self.generateUUID()
        }
    }

    func generateUUID() {
        self.userID = UUID().uuidString
        self.userDefaults.setValue(self.userID, forKey: "userID")
        Manager.shared.setUserID(userID: self.userID)
        
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        database.collection(userID).document("categories").setData([
             "order": ["전체영상","설정"]
         ])
         
        database.collection(userID).document("configurations").setData([
         "createdAt": dateFormatter.string(from: currentTime),
         "thumbnail": true,
         "playNext": true,
         "repeatSelection": ["1", "3", "5", "7", "10", "15", "무한"],
         "selectedRepeatSelection": "1",
         "userPhoneNumber": "",
         "premium": false,
         "pushEnabled": false,
         "os": "ios",
         "newMessage": false,
         "playbackSpeed": "1.0x"
        ])
         
        database.collection(userID).document("videoOrder").setData([
          "order": [""]
        ])
         
        self.loadConfigurations()
    }
    
    func loadConfigurations() {
        
        let documentReference = database.collection(self.userID).document("configurations")
        documentReference.getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else { return }
            
            Manager.shared.setManager(documentSnapShot: documentSnapshot, closure: {
                self.moveToNextScreen()                
            })
        }
    }
    
    func moveToNextScreen() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBarViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
//            homeTabBarViewController.modalPresentationStyle = .fullScreen
            let navigationController = UINavigationController(rootViewController: homeTabBarViewController)
            navigationController.modalPresentationStyle = .fullScreen
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func updateVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return }
        
        DispatchQueue.main.async {
            self.versionLabel.text = "v \(version)"
        }
    }
}

