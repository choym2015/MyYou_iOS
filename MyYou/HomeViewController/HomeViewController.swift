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
        
        self.receivedYoutubeShare()
        self.loadVideoOrder()
        self.addObserver()
        self.setFloaty()
        self.title = "마이유"
    }
    
    func setFloaty() {
        let floaty = Floaty()
        floaty.paddingX = 15
        floaty.paddingY = 40
        floaty.buttonColor = hexStringToUIColor(hex: "#6200EE")
        floaty.selectedColor = hexStringToUIColor(hex: "#DC5C60")
        floaty.plusColor = UIColor.white
        let item = FloatyItem()
        item.buttonColor = hexStringToUIColor(hex: "#6200EE")
        item.icon = UIImage(named: "edit")
        item.title = "카테고리 수정/삭제"
        item.handler = { item in
            DispatchQueue.main.async {
                item.buttonColor = self.hexStringToUIColor(hex: "#6200EE")
                let categoryListViewController = CategoryListViewController(nibName: "CategoryListViewController", bundle: Bundle.main)
                categoryListViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(categoryListViewController, animated: true)
            }
        }
        let item2 = FloatyItem()
        item2.buttonColor = hexStringToUIColor(hex: "#6200EE")
        item2.icon = UIImage(named: "link")
        item2.title = "동영상 불러오기"
        item2.handler = { item in
            DispatchQueue.main.async {

            }
        }
        let item3 = FloatyItem()
        item3.buttonColor = hexStringToUIColor(hex: "#6200EE")
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedYoutubeShare), name: Notification.Name("receivedYoutubeShare"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateCategory"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("receivedYoutubeShare"), object: nil)
    }
    
    @objc private func updateCategory() {
        self.viewControllers.removeAll()
        self.loadDB()
    }
    
    @objc private func receivedYoutubeShare() {
        let saveData = UserDefaults.init(suiteName: "group.com.chopas.jungbonet.myyouapp.share")
        guard let url = saveData?.string(forKey: "urlData") else { return }
        
        DispatchQueue.main.async {
            saveData?.set(nil, forKey: "urlData")
        }
        
        let id = url.youtubeID
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
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
