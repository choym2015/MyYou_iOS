//
//  HomeViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/22/23.
//

import UIKit
import Tabman
import Pageboy
import FirebaseFirestore
import FirebaseFirestoreInternal
import Alamofire
import Malert

class HomeViewController: TabmanViewController, TMBarDataSource {
    
    var viewControllers: [UIViewController] = []
    var tabNames = [String]()
    var tabBar: TMBarView<TMHorizontalBarLayout, TabPagerButton, TMBarIndicator.None>!
    var popupView = UIView()
    var blackView = UIView()
    var needsReload: Bool = false
    var newVideoView: NewVideoView?
    var textHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigation()
        self.setTabs()
        self.addObserver()
        self.setFloaty()
    }
    
    func setupNavigation() {
        self.navigationItem.backButtonTitle = " "
        self.navigationController?.navigationBar.barTintColor = UIColor().hexStringToUIColor(hex: "#6200EE")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.view.changeStatusBarBgColor(bgColor: UIColor.white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setTabs() {
        self.tabNames = Manager2.shared.getCategoryNames()
        self.tabNames.append("설정")
        
        DispatchQueue.main.async {
            self.populateViewControllers()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCategory), name: Notification.Name("reloadCategory"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForYoutubeShare), name: Notification.Name("receivedYoutubeShare"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reloadCategory"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("receivedYoutubeShare"), object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.newVideoView?.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.newVideoView?.frame.origin.y += keyboardSize.height
        }
    }
    
   @objc public func reloadCategory(notification: Notification) {
       self.viewControllers.removeAll()
       
       self.tabNames = Manager2.shared.getCategoryNames()
       self.tabNames.append("설정")
       
       for tabName in self.tabNames {
           var viewController: UIViewController!
           if tabName == "설정" {
               viewController = SettingsViewController(nibName: "SettingsViewController", bundle: Bundle.main)
           } else {
               viewController = VideoListViewController(nibName: "VideoListViewController", bundle: Bundle.main).receiveCategory(category: tabName)
           }
           
           self.viewControllers.append(viewController)
       }
       
       self.reloadData()
       self.tabBar.buttons.customize { (button) in
           button.update(for: .unselected)
       }
   }
    
    private static func reloadUser(closure: @escaping () -> Void) {
        let params: Parameters = ["userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable2/get_user2.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: User2.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let user = response.value else { return }
                Manager2.shared.setUser(user: user)
                closure()
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    @objc private func checkForYoutubeShare() {
        let saveData = UserDefaults.init(suiteName: "group.com.chopas.jungbonet.myyouapp.share")
        guard let url = saveData?.string(forKey: "urlData") else { return }
        
        DispatchQueue.main.async {
            saveData?.set(nil, forKey: "urlData")
        }
        
        if let id = url.youtubeID {
            self.getVideoInfo(videoID: id)
        }
    }
    
    public func populateViewControllers() {
        for tabName in tabNames {
            var viewController: UIViewController!
            if tabName == "설정" {
                viewController = SettingsViewController(nibName: "SettingsViewController", bundle: Bundle.main)
            } else {
                viewController = VideoListViewController(nibName: "VideoListViewController", bundle: Bundle.main).receiveCategory(category: tabName)
            }
            
            viewControllers.append(viewController)
        }
        
        if self.tabBar == nil {
            self.addTabBar()
        } else {
            self.removeBar(self.tabBar)
            self.addTabBar()
        }
    }
    
    private func addTabBar() {
        self.dataSource = self
        
        let bar = TMBarView<TMHorizontalBarLayout, TabPagerButton, TMBarIndicator.None>()
        bar.layout.transitionStyle = .snap
        bar.backgroundView.style = .flat(color: .white)
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 10.0, right: 20.0)
        bar.fadesContentEdges = true
        
        self.tabBar = bar
        self.addBar(self.tabBar, dataSource: self, at: .top)
        
        self.tabBar.buttons.customize { (button) in
            button.update(for: .unselected)
        }
    }
    
    func getVideoInfo(videoID: String) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?id=\(videoID)&key=AIzaSyBVWwUR7x6-axUKWIQn9pH6tl8MS_4vPfE&part=snippet,contentDetails,statistics,status")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, reponse, error) in
            guard error == nil else {
                print("UNABLE TO FETCH YOUTUBE INFO")
                return
            }
            
            guard let content = data,
                  let jsonArray = try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {
                print("UNABLE TO PARSE YOUTUBE INFO")
                return
            }
            
            guard let itemJson = jsonArray["items"] as? [[String: Any]],
                  let id = itemJson[0]["id"] as? String,
                  let snippet = itemJson[0]["snippet"] as? [String: AnyObject],
                  let title = snippet["title"] as? String else {
                print("UNABLE TO PARSE YOUTUBE JSON")
                return
            }

            DispatchQueue.main.async {
                self.addVideoFromShare(title: title, videoID: id)
            }
        }
        task.resume()
    }
    
    public static func reload(closure: @escaping () -> Void) {
        HomeViewController.reloadUser {
            closure()
        }
    }
}

class TabPagerButton: Tabman.TMLabelBarButton {
    override func update(for selectionState: TMBarButton.SelectionState) {
        contentInset = UIEdgeInsets(top: 15.0, left: 20.0, bottom: 10.0, right: 20.0)
        roundCorners(corners: .allCorners, radius: 20)
        
        switch selectionState {
        case .selected:
            backgroundColor = UIColor().hexStringToUIColor(hex: "#8851F5")
            tintColor = .white
            selectedTintColor = .white
        default:
            backgroundColor = UIColor().hexStringToUIColor(hex: "#f8f8f8")
            tintColor = UIColor().hexStringToUIColor(hex: "#686868")
            selectedTintColor = UIColor().hexStringToUIColor(hex: "#686868")
        }

        super.update(for: selectionState)
    }
}
