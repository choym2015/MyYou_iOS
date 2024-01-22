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
    
    let userID = Manager.shared.getUserID()
    var viewControllers: [UIViewController] = []
    var tabNames = [String]()
    var tabBar: TMBarView<TMHorizontalBarLayout, TabPagerButton, TMBarIndicator.None>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = " "
        self.navigationController?.navigationBar.barTintColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        self.setTabs()
        self.addObserver()
        self.setFloaty()
        self.title = "마이유"
        if UserDefaults.standard.value(forKey: "authConfirmed") != nil {
            
        } else {
            //print("auth should show")
            //self.showAuthDialog()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.view.changeStatusBarBgColor(bgColor: UIColor.white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setTabs() {
        self.tabNames = Manager.shared.getCategories()
        
        DispatchQueue.main.async {
            self.populateViewControllers()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCategory), name: Notification.Name("updateCategory"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForYoutubeShare), name: Notification.Name("receivedYoutubeShare"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateCategory"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("receivedYoutubeShare"), object: nil)
    }
    
    @objc private func updateCategory() {
        self.viewControllers.removeAll()
        self.reloadCategories()
    }
    
    private func reloadCategories() {
        let params: Parameters = ["userID" : self.userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable/get_categories.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: Category.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let categories = response.value?.categories.components(separatedBy: ",") else { return }
                
                self.tabNames = categories
                Manager.shared.setCategories(categories: categories)
                
                DispatchQueue.main.async {
                    self.populateViewControllers()
                }
                
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
        
        
        let id = url.youtubeID!
        getVideoInfo(videoID: id)
    }
    
    @IBAction func addList(_ sender: Any) {
        createNewList()
    }
    
    let videoAddLauncher = VideoAddLauncher()
    private func createNewList() {
        // Pop-up view should take place above. 
        videoAddLauncher.showSettings()
    }
    
    private func populateViewControllers() {
        //populate view controllers here
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

            self.addVideoFromShare(title: title, videoID: id)
        }
        task.resume()
    }
    
    private func addVideoFromShare(title: String, videoID: String) {
        var videoOrder = Manager.shared.getVideoOrderList()
        
        guard let firstItem = videoOrder.first else { return }
        
        if firstItem.isEmpty {
            videoOrder[0] = videoID
        } else {
            videoOrder.insert(videoID, at: 0)
        }
        
        let listString = videoOrder.joined(separator: ",")
        
        let params: Parameters = [
            "videoID" : videoID,
            "userID" : self.userID,
            "title" : title,
            "videoOrder" : listString]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable/create_product.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setVideoOrderList(videoOrderList: videoOrder)
                self.updateCategory()
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
//    func showAuthDialog() {
//        //show dialog
//        print("auth showing")
//        let view = AuthDialogView.instantiateFromNib()
//        view.titleText.text = "다른 사용자에게 동영상을 받으시려면 본인인증이\n필요합니다."
//        
//        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: false)
//        
//        malert.buttonsAxis = .vertical
//        malert.buttonsSpace = 10
//        malert.buttonsSideMargin = 20
//        malert.buttonsBottomMargin = 20
//        malert.cornerRadius = 10
//        malert.separetorColor = .clear
//        malert.animationType = .fadeIn
//        
//        malert.presentDuration = 1.0
//        
//        view.confirmButton.layer.cornerRadius = 10
//        view.confirmButton.addTarget(self, action: #selector(pressedConfirm), for: .touchUpInside)
//        view.skipButton.layer.cornerRadius = 10
//        view.skipButton.addTarget(self, action: #selector(pressedSkip), for: .touchUpInside)
//        
//        //if user says ok -> AuthViewController
//        //if user says no -> showNextTimeDialog
//        
//        let alert = UIAlertController(title: "마이유", message: "다른 사용자에게 동영상을 받으시려면 본인인증이 필요합니다. 본인인증을 진행하시겠습니까?", preferredStyle: .actionSheet)
//        
//        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
//            //performSegue to AuthorizeViewController
//        }))
//        alert.addAction(UIAlertAction(title: "다음에", style: .cancel, handler: { action in
//            self.pressedSkip()
//        }))
//        DispatchQueue.main.async {
//            self.present(malert, animated: true, completion: nil)
//        }
//    }
//    
//    @objc func pressedConfirm() {
//        
//    }
//    
//    @objc func pressedSkip() {
//        //create nextTimeDialog
//    }
}

class TabPagerButton: Tabman.TMLabelBarButton {
    override func update(for selectionState: TMBarButton.SelectionState) {
        contentInset = UIEdgeInsets(top: 15.0, left: 20.0, bottom: 10.0, right: 20.0)
        roundCorners(corners: .allCorners, radius: 20)
        
        switch selectionState {
        case .selected:
            backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
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
