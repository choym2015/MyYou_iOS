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
                if Manager2.shared.user.userPhoneNumber.isEmpty {
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
    
    func addVideoDialog(title: String, videoID: String) {
        self.popupView = {
            let view = NewVideoView.instantiateFromNib()
            view.titleTextField.text = title
            view.receiveItem(videoID: videoID)
            
            if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoID))/maxresdefault.jpg") {
                view.thumbnailView.downloadImage(from: url)
            } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoID))/default.jpg") {
                view.thumbnailView.downloadImage(from: url)
            } else {
                view.thumbnailView.isHidden = true
            }
            
            self.categoryButton = view.categoryButton
            self.categoryButton.layer.borderWidth = 0.5
            self.categoryButton.layer.cornerRadius = 10
            self.categoryButton.addTarget(self, action: #selector(showCategories), for: .touchUpInside)
            
            view.addButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
            view.addButton.layer.cornerRadius = 10
            
//            view.addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
            view.cancelImageView.isUserInteractionEnabled = true
            view.cancelImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            return view
        }()
        
        if let window = UIApplication.shared.keyWindow {
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(self.blackView)
            window.addSubview(self.popupView)
            
            let height: CGFloat = window.frame.height * 0.7
            let y = window.frame.height - height
            self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            self.blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.popupView.frame = CGRect(x: 0, y: y, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
        }
    }
    
    @objc func addItem(sender: UIButton) {
    
    }
    
    @objc func showCategories() {
        DispatchQueue.main.async {
            let selectCategoryVC = SelectCategoryViewController(nibName: "SelectCategoryViewController", bundle: Bundle.main)
            
            selectCategoryVC.receiveItem(selectedCategory: nil) { newCategory in
                
            }
            
            selectCategoryVC.transitioningDelegate = self
            selectCategoryVC.modalPresentationStyle = .custom
            self.presentedViewController?.present(selectCategoryVC, animated: true)
            self.present(selectCategoryVC, animated: true)
        }
    }
    
    func getCategory(categoryID: String) -> Category? {
        guard let index = Manager2.shared.user.categoryIDs.firstIndex(of: categoryID) else {
            return nil
        }
        
        return Manager2.shared.user.categories[index]
    }
}

extension HomeViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 30, y: containerViewFrame.height / 6), size: CGSize(width: containerViewFrame.width-60, height: containerViewFrame.height * (2/3) - 100 ))
    }
    
    // return a Bonsai Controller with SlideIn or Bubble transition animator
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .dark, presentedViewController: presented, delegate: self)
    }
}
