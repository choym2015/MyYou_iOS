//
//  SettingsViewController+Network.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/16/24.
//

import Foundation
import Alamofire
import FirebaseMessaging
extension SettingsViewController {
    func updateThumbnail(thumbnail: Bool) {
        let params: Parameters = ["thumbnail" : String(describing: thumbnail), "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable/update_thumbnail.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setShouldShowThumbnail(shouldShowThumbnail: thumbnail)
                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func updateCategories(categories: [String]) {
        let listString = categories.joined(separator: ",")
        let params: Parameters = ["categories" : listString, "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable/update_categories.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setCategories(categories: categories)
                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func updatePlayNext(playNext: Bool) {
        let params: Parameters = ["playNext" : String(describing: playNext), "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable/update_play_next.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setShouldPlayNext(shouldPlayNext: playNext)
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func updatePro(subscription: String) {
        let params: Parameters = ["subscription" : subscription, "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable/update_subscription.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setSubscription(subscription: subscription)
                DispatchQueue.main.async {
                    self.setupSubscriptionUI()
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func updatePushEnabled(pushEnabled: Bool) {
        let params: Parameters = ["pushEnabled" : String(describing: pushEnabled), "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable/update_push_enabled.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setPushEnabled(pushEnabled: pushEnabled)
                let userPhoneNumber = Manager.shared.getUserPhoneNumber()
                if pushEnabled {
                    Messaging.messaging().subscribe(toTopic: "myyou_pro_\(userPhoneNumber)")
                } else {
                    Messaging.messaging().unsubscribe(fromTopic: "myyou_pro_\(userPhoneNumber)")
                }
                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
