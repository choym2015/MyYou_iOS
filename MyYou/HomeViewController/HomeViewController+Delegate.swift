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

extension HomeViewController: PageboyViewControllerDataSource, BonsaiControllerDelegate, UITextViewDelegate {
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
            self.newVideoView = NewVideoView.instantiateFromNib()
            self.newVideoView?.receiveItem(videoID: videoID)
            self.newVideoView?.titleTextView.text = title
            self.newVideoView?.titleTextView.delegate = self

            self.textHeightConstraint = self.newVideoView?.titleTextView.heightAnchor.constraint(equalToConstant: 40)
            self.textHeightConstraint.isActive = true
            self.adjustTextViewHeight(textView: self.newVideoView!.titleTextView)
            
            self.newVideoView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
            
            if let lastCategory = Helper.getCategory(categoryID: Manager2.shared.user.lastCategory) {
                self.newVideoView?.categoryButton.setTitle(lastCategory.categoryName, for: .normal)
                self.newVideoView?.categoryButton.semanticContentAttribute = UIApplication.shared
                    .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
            }
            
            if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoID))/maxresdefault.jpg") {
                self.newVideoView?.thumbnailImageView.downloadImage(from: url)
            } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoID))/default.jpg") {
                self.newVideoView?.thumbnailImageView.downloadImage(from: url)
            } else {
                self.newVideoView?.thumbnailImageView.isHidden = true
            }
            
            self.newVideoView?.categoryButton.layer.borderWidth = 0.5
            self.newVideoView?.categoryButton.layer.cornerRadius = 10
            self.newVideoView?.categoryButton.addTarget(self, action: #selector(showCategories), for: .touchUpInside)
            
            self.newVideoView?.addButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
            self.newVideoView?.addButton.layer.cornerRadius = 10
            self.newVideoView?.addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
            
            self.newVideoView?.cancelImageView.isUserInteractionEnabled = true
            self.newVideoView?.cancelImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            return self.newVideoView!
        }()
        
        if let window = self.view.window {
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(self.blackView)
            window.addSubview(self.popupView)
            
            
            let newHeight = 600 - 82.67 + self.textHeightConstraint.constant
            self.newVideoView?.heightConstraint.constant = newHeight
            let y = window.frame.height - newHeight
            self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: newHeight)
            
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
            if let window = self.view.window {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
            
            if self.needsReload {
                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        if self.newVideoView?.titleTextView.isFirstResponder != nil {
            self.newVideoView?.titleTextView.resignFirstResponder()
        }
    }
    
    @objc func addItem() {
        self.needsReload = true
        
        guard let newVideoView = self.newVideoView else { return }
        var videoIDs = Manager2.shared.getVideoIDs()
        
        guard let firstItem = videoIDs.first,
              let videoID = newVideoView.videoID,
              let title = newVideoView.titleTextView.text.replacingOccurrences(of: "'", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        if firstItem.isEmpty {
            videoIDs[0] = videoID
        } else {
            videoIDs.insert(videoID, at: 0)
        }
        
        let listString = videoIDs.joined(separator: ",")
        let selectedCategory = Helper.getCategory(categoryName: newVideoView.categoryButton.titleLabel?.text)
        
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
                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
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
    
    @objc func showCategories() {
        DispatchQueue.main.async {
            let selectCategoryVC = SelectCategoryViewController(nibName: "SelectCategoryViewController", bundle: Bundle.main)
            let selectedCategory = Helper.getCategory(categoryName: self.newVideoView?.categoryButton.titleLabel?.text)
            
            selectCategoryVC.receiveItem(selectedCategory: selectedCategory) { newCategory in
                guard let categoryButton = self.newVideoView?.categoryButton else { return }
                
                if let selectedCategory = categoryButton.titleLabel?.text {
                    if selectedCategory == newCategory.categoryName {
                        categoryButton.setTitle("------", for: .normal)
                    } else {
                        categoryButton.setTitle(newCategory.categoryName, for: .normal)
                    }
                } else {
                    categoryButton.setTitle(newCategory.categoryName, for: .normal)
                }
            }
            
            selectCategoryVC.transitioningDelegate = self
            selectCategoryVC.modalPresentationStyle = .custom
            self.present(selectCategoryVC, animated: true)
        }
    }
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 30, y: containerViewFrame.height / 6), size: CGSize(width: containerViewFrame.width-60, height: containerViewFrame.height * (2/3) - 100 ))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .dark, presentedViewController: presented, delegate: self)
    }
    
    func adjustTextViewHeight(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textHeightConstraint.constant = newSize.height
        self.view.layoutIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight(textView: textView)
    }
}


