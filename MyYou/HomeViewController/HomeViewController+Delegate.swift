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

extension HomeViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.viewControllers.count
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
        messageListItem.title = "동영상 불러오기"
        messageListItem.handler = { item in
            DispatchQueue.main.async {
                if Manager.shared.getUserPhoneNumber().isEmpty {
                    NotificationPresenter.shared.present("본인 인증 후에 사용할 수 있는 기능입니다", includedStyle: .error)
                    //move to auth viewcontroller
                }
            }
        }
        
        let sendVideoItem = FloatyItem()
        sendVideoItem.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        sendVideoItem.icon = UIImage(named: "premium")
        sendVideoItem.title = "동영상 보내기"
        sendVideoItem.handler = { item in
            DispatchQueue.main.async {
                if Manager.shared.getSubscription() != "pro" {
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
}
