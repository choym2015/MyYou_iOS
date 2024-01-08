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
        floaty.addItem("카테고리 수정/삭제", icon: UIImage(named: "edit", in: Bundle.main, with: nil)) { item in
            DispatchQueue.main.async {
                let categoryListViewController = CategoryListViewController(nibName: "CategoryListViewController", bundle: Bundle.main)
                categoryListViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(categoryListViewController, animated: true)
            }
        }
        floaty.addItem("동영상 불러오기", icon: UIImage(named: "download", in: Bundle.main, with: nil)) { item in
            DispatchQueue.main.async {
            }
        }
        floaty.addItem("동영상 보내기", icon: UIImage(named: "premium", in: Bundle.main, with: nil)) { item in
            DispatchQueue.main.async {
            }
        }
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
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self, name: Notification.Name("updateCategory"), object: nil)
    }
    
    @objc private func updateCategory() {
        self.viewControllers.removeAll()
        self.loadDB()
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

