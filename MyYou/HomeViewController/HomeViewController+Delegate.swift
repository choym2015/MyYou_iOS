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
                    NotificationPresenter.shared.present("본인 인증 후에 사용할 수 있는 기능입니다", includedStyle: .error)
                    //move to auth viewcontroller
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
                    NotificationPresenter.shared.present("마이유 프로만 사용할 수 있는 기능입니다", includedStyle: .error)
                } else {
                    //show send dialog
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
    
    func addVideoFromShare(title: String, videoID: String) {
        self.needsReload = true
        
        var videoIDs = Manager2.shared.getVideoIDs()
        
        guard let firstItem = videoIDs.first,
              let title = title.replacingOccurrences(of: "'", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        if firstItem.isEmpty {
            videoIDs[0] = videoID
        } else {
            videoIDs.insert(videoID, at: 0)
        }
        
        let listString = videoIDs.joined(separator: ",")
        let selectedCategory = Helper.getCategory(categoryName: "임시")
        
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "videoID" : videoID,
            "title" : title,
            "categoryName" : selectedCategory?.categoryName ?? "",
            "categoryID" : selectedCategory?.categoryID ?? "",
            "videoIDs" : listString
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable2/create_product.php/",
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
                    UIView.animate(withDuration: 0.5) {
                        self.blackView.alpha = 0
                        if let window = self.view.window {
                            self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
                        }
                    }
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
//    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
//        return CGRect(origin: CGPoint(x: 30, y: containerViewFrame.height / 6), size: CGSize(width: containerViewFrame.width-60, height: containerViewFrame.height * (2/3) - 100 ))
//    }
//    
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .dark, presentedViewController: presented, delegate: self)
//    }
    
}


