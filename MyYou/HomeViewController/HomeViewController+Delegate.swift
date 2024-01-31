//
//  HomeViewController+Delegate.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/26/23.
//

import Foundation
import Pageboy
import Tabman
import Floaty
import JDStatusBarNotification
import BonsaiController
import Alamofire
import Malert

extension HomeViewController: PageboyViewControllerDataSource, UITextViewDelegate {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.tabNames.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return self.viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: self.tabNames[index])
    }
    
    func setFloaty() {
        let floaty = Floaty()
        floaty.paddingX = 15
        floaty.paddingY = 40
        floaty.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        floaty.selectedColor = UIColor().hexStringToUIColor(hex: "#DC5C60")
        floaty.plusColor = UIColor.white
        
        let categoryEditItem = FloatyItem()
        categoryEditItem.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        categoryEditItem.icon = UIImage(named: "edit")
        categoryEditItem.title = "카테고리 수정/삭제"
        categoryEditItem.handler = { item in
            DispatchQueue.main.async {
                categoryEditItem.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
                let categoryListViewController = CategoryListViewController(nibName: "CategoryListViewController", bundle: Bundle.main)
                categoryListViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(categoryListViewController, animated: true)
            }
        }
        
        let messageListItem = FloatyItem()
        messageListItem.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        messageListItem.icon = UIImage(named: "link")
        messageListItem.title = "카테고리 불러오기"
        messageListItem.handler = { item in
            DispatchQueue.main.async {
                if Manager2.shared.user.userPhoneNumber.isEmpty {
                    NotificationPresenter.shared.present("본인 인증 후에 사용할 수 있는 기능입니다", includedStyle: .error, duration: 2.0)
                    let authVC = AuthUserViewController(nibName: "AuthUserViewController", bundle: Bundle.main)
                    authVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(authVC, animated: true)
                } else {
                    let messageListVC = MessageListViewController(nibName: "MessageListViewController", bundle: Bundle.main)
                    messageListVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(messageListVC, animated: true)
                }
            }
        }
        
        let sendVideoItem = FloatyItem()
        sendVideoItem.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        sendVideoItem.icon = UIImage(named: "premium")
        sendVideoItem.title = "카테고리 보내기"
        sendVideoItem.handler = { item in
            DispatchQueue.main.async {
                if Manager2.shared.user.subscription != "pro" {
                    NotificationPresenter.shared.present("마이유 프로만 사용할 수 있는 기능입니다", includedStyle: .error, duration: 2.0)
                } else {
                    let sendVideoVC = SendVideoViewController(nibName: "SendVideoViewController", bundle: Bundle.main)
                    sendVideoVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(sendVideoVC, animated: true)
                }
            }
        }
        
        floaty.addItem(item: categoryEditItem)
        floaty.addItem(item: messageListItem)
        floaty.addItem(item: sendVideoItem)
        
        DispatchQueue.main.async {
            self.view.addSubview(floaty)
        }
    }
    
    func addVideoFromShare(title: String, youtubeID: String) {
        self.needsReload = true
        let youtubeIDs = Manager2.shared.user.videoItems.map { videoItem in
            videoItem.youtubeID
        }
        
        guard !youtubeIDs.contains(youtubeID) else {
            NotificationPresenter.shared.present("동영상을 중복으로 추가할 수 없습니다.", includedStyle: .error, duration: 2.0)
            return
        }
        
        let videoID = UUID().uuidString
        guard let selectedCategory = Helper.getCategory(categoryName: "임시") else { return }
        selectedCategory.addVideoID(videoID: videoID)

        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "videoID" : videoID,
            "youtubeID" : youtubeID,
            "title" : title.encodeUrl(),
            "categoryID" : selectedCategory.categoryID,
            "videoIDs" : selectedCategory.videoIDs.joined(separator: ",")
        ]

        AF.request("https://chopas.com/smartappbook/myyou/videoTable3/create_product2.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                    }
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func showNewMessage() {
        NetworkManager.updateNewMessage(newMessage: false)
        let view = NewMessageDialogView.instantiateFromNib()
        
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
                    let messageListVC = MessageListViewController(nibName: "MessageListViewController", bundle: Bundle.main)
                    messageListVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(messageListVC, animated: true)
                }
            }
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#8851f5")
        completeButton.tintColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        
        let cancelButton = MalertAction(title: "다음에") {
            malert.dismiss(animated: true)
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
}


