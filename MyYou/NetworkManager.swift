//
//  NetworkManager.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/29/24.
//

import Foundation
import Alamofire
import FirebaseMessaging
import JDStatusBarNotification

public class NetworkManager {
    public static func createCategory(newCategory: Category, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "categoryID" : newCategory.categoryID,
            "ownerID" : newCategory.ownerID,
            "categoryName" : newCategory.categoryName,
            "referenceCategoryID" : newCategory.referenceCategoryID,
            "categoryIDs" : Manager2.shared.user.categoryIDs.joined(separator: ",")
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/create_category.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updateCategoryName(oldCategory: Category, newCategoryName: String, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {

        let params: Parameters = [
            "categoryID" : oldCategory.categoryID,
            "oldCategoryName" : oldCategory.categoryName,
            "newCategoryName" : newCategoryName
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/update_category_name.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func getReferenceUsersForCategory(category: Category, completionHandler: @escaping (DataResponse<Audiences, AFError>) -> Void) {

        let params: Parameters = [
            "categoryID" : category.categoryID
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/get_reference_users.php",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: Audiences.self, completionHandler: completionHandler)
    }
    
    public static func deleteCategory(category: Category, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {

        let params: Parameters = [
            "categoryID" : category.categoryID,
            "categoryName" : category.categoryName,
            "categoryIDs" : Manager2.shared.user.categoryIDs.joined(separator: ","),
            "ownerID": Manager2.shared.getUserID()
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/delete_category.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updateLastCategory(lastCategoryID: String) {
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "lastCategoryID" : lastCategoryID
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_last_category.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                print("LAST CATEGORY UPDATED")
            case .failure:
                print("LAST CATEGORY FAILED TO UPDATE")
            }
        })
    }
    
    public static func updateVideoCategory(videoItem: VideoItem, oldCategory: Category, newCategory: Category, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {

        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "title" : videoItem.title,
            "videoID" : videoItem.videoID,
            "oldCategoryID": oldCategory.categoryID,
            "oldCategoryVideoIDs": oldCategory.videoIDs.joined(separator: ","),
            "newCategoryID": newCategory.categoryID,
            "newCategoryVideoIDs": newCategory.videoIDs.joined(separator: ","),
            "isOwner": videoItem.isOwner() ? "true" : "false"
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable3/update_video.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func deleteVideo(videoItem: VideoItem, category: Category, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
        var deleteUrl: String = ""
        if videoItem.isOwner() {
            deleteUrl = "https://chopas.com/smartappbook/myyou/videoTable3/delete_video2.php"
        } else {
            deleteUrl = "https://chopas.com/smartappbook/myyou/videoTable3/delete_video_reference.php"
        }

        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "categoryID" : category.categoryID,
            "videoID" : videoItem.videoID,
            "videoIDs": category.videoIDs.joined(separator: ",")
        ]
        
        AF.request(deleteUrl,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updateUserPhoneNumber(userPhoneNumber: String, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "userPhoneNumber" : userPhoneNumber
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_phone_number.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updatePushNotification(pushEnabled: Bool, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
        if pushEnabled {
            Messaging.messaging().subscribe(toTopic: "myyou_pro_\(Manager2.shared.getUserPhoneNumber())")
        } else {
            Messaging.messaging().unsubscribe(fromTopic: "myyou_pro_\(Manager2.shared.getUserPhoneNumber())")
        }
        
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "pushEnabled" : pushEnabled ? "true" : "false"
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_push_enabled.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updateCategoryIDs(categoryIDs: [String], completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
                
        let params: Parameters = [
            "userID" : MyUserDefaults.getString(with: "userID")!,
            "categoryIDs" : categoryIDs.joined(separator: ",")
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_category_ids.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updateReferenceCategory(referenceCategory: Category, messageItem: MessageItem, referenceCategoryVideoIDs: [String], completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
                
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "categoryID" : referenceCategory.categoryID,
            "referenceCategoryID": messageItem.category.categoryID,
            "videoIDs": referenceCategoryVideoIDs.joined(separator: ","),
            "messageID": messageItem.messageID
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/update_reference_category.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func receiveCategory(category: Category, videoIDs: [String], messageID: String, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
        let newCategoryID = UUID().uuidString
        var categoryIDs = Manager2.shared.getCategoryIDs()
        categoryIDs.insert(newCategoryID, at: 1)
        
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "categoryID" : newCategoryID,
            "categoryIDs": categoryIDs.joined(separator: ","),
            "referenceCategoryID": category.categoryID,
            "videoIDs": videoIDs.joined(separator: ","),
            "categoryName": category.categoryName,
            "messageID": messageID
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/create_category_reference.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func updateCategoryVideoIDs(category: Category, videoIDs: [String], completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
        let params: Parameters = [
            "userID" : MyUserDefaults.getString(with: "userID")!,
            "categoryID" : category.categoryID,
            "videoIDs" : videoIDs.joined(separator: ",")
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable3/update_video_ids.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func createMessage(phoneNumbers: [String], videoIDs: [String], messageIDs: [String], category: Category, completionHandler: @escaping (DataResponse<SimpleResponse<String>, AFError>) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
        let date = dateFormatter.string(from: Date())

        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "messageIDs" : messageIDs.joined(separator: ","),
            "categoryID" : category.categoryID,
            "videoIDs" : videoIDs.joined(separator: ","),
            "categoryName" : category.categoryName,
            "timestamp" : date,
            "senderPhoneNumber" : Manager2.shared.getUserPhoneNumber(),
            "receiverPhoneNumbers" : phoneNumbers.joined(separator: ",")
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/messageTable3/create_product.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: completionHandler)
    }
    
    public static func postFirebasePush(phoneNumber: String, category: Category, messageID: String) {
                
        let params: Parameters = [
            "to": "/topics/myyou_pro_\(phoneNumber)",
            "data": [
                "categoryID": category.categoryID,
                "categoryName": category.categoryName,
                "messageID": messageID,
                "action": "sendVideo"
            ],
            "notification": [
                "title": "마이유",
                "body": "새로운 동영상 리스트를 받았습니다.\n앱을 열어서 확인해보세요",
                "sound": "default"
            ]
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "key=\(Manager2.shared.getAndroidFCMKey())"
        ]
        
        AF.request("https://fcm.googleapis.com/fcm/send",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: headers)
        
        .validate(statusCode: 200..<300)
        .response { _ in }
    }
    
    public static func updateNewMessage(newMessage: Bool) {
        let params: Parameters = ["newMessage" : String(describing: newMessage), "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_new_message.php",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager2.shared.user.newMessage = newMessage
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
