//
//  DownloadMessageViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import UIKit
import Alamofire
import JDStatusBarNotification

class DownloadMessageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var receiveCategoryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    var message: MessageItem!
    var closure: ((Bool) -> Void)!
    var videos: [VideoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.loadVideos()
    }
    
    public func receiveItem(message: MessageItem, closure: @escaping ((Bool) -> Void)) {
        self.message = message
        self.closure = closure
    }
    
    func setupUI() {
        self.title = "카테고리: " + self.message.category.categoryName
        navigationItem.backButtonTitle = " "
        self.view.changeStatusBarBgColor(bgColor: UIColor().hexStringToUIColor(hex: "#6200EE"))
        navigationController?.navigationBar.tintColor = UIColor.white
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            let barAppearence = UIBarButtonItemAppearance()
            barAppearence.normal.titleTextAttributes = [.foregroundColor: UIColor.yellow]
            appearance.buttonAppearance = barAppearence
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.standardAppearance = appearance
        }
        
        self.cancelButton.layer.cornerRadius = 10
        self.receiveCategoryButton.layer.cornerRadius = 10
    }
    
    func loadVideos() {
        let params: Parameters = [
            "videoIDs" : message.videoIDs
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable3/get_videos_by_id2.php",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: VideoItemList.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let videoItems = response.value?.product else { return }
                self.videos = videoItems

                DispatchQueue.main.async {
                    self.setCollectionView()
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error, duration: 2.0)
            }
        })
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoCollectionViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
        layout.minimumLineSpacing = 40
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 50)
        
        self.collectionView.collectionViewLayout = layout
    }


    @IBAction func receiveCategoryButtonPressed(_ sender: UIButton) {
        let referenceCategoryIDs = Manager2.shared.user.categories.map { $0.referenceCategoryID }
        if let index = referenceCategoryIDs.firstIndex(of: message.category.categoryID) {
            let referenceCategory = Manager2.shared.user.categories[index]
            let videoIDs = message.videoIDs.components(separatedBy: ",")
            var referenceCategoryVideoIDs = referenceCategory.videoIDs
            
            for videoID in videoIDs {
                if !Manager2.shared.user.videoItems.contains(where: { videoItem in
                    videoItem.videoID == videoID
                }) {
                    referenceCategoryVideoIDs.insert(videoID, at: 0)
                }
            }
 
            NetworkManager.updateReferenceCategory(referenceCategory: referenceCategory, messageItem: message, referenceCategoryVideoIDs: referenceCategoryVideoIDs) { response in
                switch response.result {
                case .success:
                    HomeViewController.reload {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                case .failure(let failure):
                    NotificationPresenter.shared.present(failure.localizedDescription, includedStyle: .error, duration: 2.0)
                }
            }
        } else {
            let videoIDs = self.videos.map { $0.videoID }

            NetworkManager.receiveCategory(category: message.category, videoIDs: videoIDs, messageID: message.messageID, completionHandler: { response in
                switch response.result {
                case .success:
                    HomeViewController.reload {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                case .failure(let failure):
                    NotificationPresenter.shared.present(failure.localizedDescription, includedStyle: .error, duration: 2.0)
                }
            })
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
