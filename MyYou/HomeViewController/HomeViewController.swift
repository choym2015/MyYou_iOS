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
import Floaty

class HomeViewController: TabmanViewController, TMBarDataSource {
    
    let userID = Manager.shared.getUserID()
    let database = Manager.shared.getDB()
    
    var videoURL = "string example"
    var videoType = "category type"
    var videoThumbnail = "some type of image name"
    
    var viewControllers: [UIViewController] = []
    
    var tabNames = [String]()
    
    var tabBar: TMBarView<TMHorizontalBarLayout, TabPagerButton, TMBarIndicator.None>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadVideoOrder()
        self.addObserver()
        self.setFloaty()
        self.title = "마이유"
    }
    
    func setFloaty() {
        let floaty = Floaty()
        floaty.paddingX = 15
        floaty.paddingY = 40
        floaty.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        floaty.selectedColor = UIColor().hexStringToUIColor(hex: "#DC5C60")
        floaty.plusColor = UIColor.white
        let item = FloatyItem()
        item.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        item.icon = UIImage(named: "edit")
        item.title = "카테고리 수정/삭제"
        item.handler = { item in
            DispatchQueue.main.async {
                item.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
                let categoryListViewController = CategoryListViewController(nibName: "CategoryListViewController", bundle: Bundle.main)
                categoryListViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(categoryListViewController, animated: true)
            }
        }
        let item2 = FloatyItem()
        item2.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        item2.icon = UIImage(named: "link")
        item2.title = "동영상 불러오기"
        item2.handler = { item in
            DispatchQueue.main.async {

            }
        }
        let item3 = FloatyItem()
        item3.buttonColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        item3.icon = UIImage(named: "premium")
        item3.title = "동영상 보내기"
        item3.handler = { item in
            DispatchQueue.main.async {
            }
        }
        floaty.addItem(item: item)
        floaty.addItem(item: item2)
        floaty.addItem(item: item3)
        self.view.addSubview(floaty)
    }
    
    func loadVideoOrder() {
        let docRef = database.collection(userID).document("videoOrder")
        docRef.getDocument { document, error in
            guard let document = document,
                  let order = document.get("order") as? [String] else {
                print("NO DOCUMENT")
                return
            }
            
            Manager.shared.setVideoOrderList(videoOrderList: order)
            self.loadDB()
        }
    }
    
    func loadDB() {
        let docRef = database.collection(userID).document("categories")
        
        docRef.getDocument { document, error in
            guard let document = document,
                  let order = document.get("order") as? [String] else {
                print("NO DOCUMENT")
                return
            }
                    
            self.tabNames = order
            Manager.shared.setCategories(categories: order)
            
            DispatchQueue.main.async {
                self.populateViewControllers()
            }
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
        self.loadDB()
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
            
            self.database.collection(self.userID).document("video_" + id).setData([
              "title": title,
              "videoID": id,
              "liked": false,
              "time": "",
              "category": ""
            ])
            
            self.updateCategory()
        }
        task.resume()
    }
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
