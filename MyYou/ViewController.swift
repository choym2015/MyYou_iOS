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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.value(forKey: "userID") == nil {
            generateUUID()
        } else {
            print("UUID exists. moving on.")
            moveToNextScreen()
        }
        
    }

    func generateUUID() {
        let userID = UUID().uuidString
        userDefaults.setValue(userID, forKey: "userID")
        print("UUID created.")
        
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-m-dd hh.mm:ss.sss"
        
        do {
           database.collection(userID).document("categories").setData([
                "order": ["전체영상","설정"]
            ])
            
           database.collection(userID).document("configurations").setData([
            "createdAt": dateFormatter.string(from: currentTime),
            "thumbnail": true,
            "showAll": true,
            "playNext": true,
            "repeatSelection": ["1", "3", "5", "7", "10", "15", "무한"],
            "selectedRepeatSelection": "1",
            "userPhoneNumber": "",
            "premium": false,
            "pushEnabled": false,
            "os": "ios"
            //"videoOrder": ["order": ""]
            
           ])
            
           database.collection(userID).document("videoOrder").setData([
             "order": [""]
           ])
            
          print("Document successfully written!")
            self.moveToNextScreen()
        } catch {
          print("Error writing document: \(error)")
        }

    }
    
    func moveToNextScreen() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBarViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            homeTabBarViewController.modalPresentationStyle = .fullScreen
            
            self.present(homeTabBarViewController, animated: true, completion: nil)
        }
    }
    
}

