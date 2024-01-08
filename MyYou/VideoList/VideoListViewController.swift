//
//  VideoListViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import UIKit
import Malert
import JDStatusBarNotification

class VideoListViewController: UIViewController {
    var category: String!
    var videos: [VideoItem]! = []
    let database = Manager.shared.getDB()
    let userID = Manager.shared.getUserID()
    private var doubleTapGesture: UITapGestureRecognizer!

    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var categoryButton: UIButton!
    
    var selectedCategory: String! {
        didSet {
            selectedCategory.isEmpty ? categoryButton.setTitle("------", for: .normal) : categoryButton.setTitle(selectedCategory, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadDb()
    }
    
    public func receiveCategory(category: String) -> UIViewController {
        self.category = category
        return self
    }

    func loadDb() {
        database.collection(userID).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            
            let documents = querySnapshot.documents.filter { querySnapshotDocument in
                querySnapshotDocument.documentID.starts(with: "video_")
            }
            
            
            for document in documents {
                guard let videoID = document.get("videoID") as? String,
                      let title = document.get("title") as? String,
                      let liked = document.get("liked") as? Bool,
                      let time = document.get("time") as? String,
                      let category = document.get("category") as? String else { return }
                
                if self.category != "전체영상" && category != self.category {
                    continue
                }
                
                let videoItem = VideoItem(videoID: videoID, title: title, liked: liked, time: time, category: category)
                self.videos.append(videoItem)
            }
            
            DispatchQueue.main.async {
                self.setCollectionView()
                self.emptyLabel.isHidden = !self.videos.isEmpty
            }
        }
    }
    
    private func setCollectionView() {
        self.collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoCollectionViewCell")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 30
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 500)
        
        self.collectionView.collectionViewLayout = layout
        self.setUpDoubleTap()
    }
    
    func setUpDoubleTap() {
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapCollectionView))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.collectionView.addGestureRecognizer(self.doubleTapGesture)
        self.doubleTapGesture.delaysTouchesBegan = true
    }
    
    @objc func didDoubleTapCollectionView() {
        let pointInCollectionView = self.doubleTapGesture.location(in: self.collectionView)
        if let selectedIndexPath = self.collectionView.indexPathForItem(at: pointInCollectionView) {
            let videoItem = self.videos[selectedIndexPath.row]

            self.showVideoEdit(videoItem: videoItem)
        }
    }
    
    func showVideoEdit(videoItem: VideoItem) {
        let view = VideoEditView.instantiateFromNib()
        view.videoTitleTextField.text = videoItem.title
        
        self.categoryButton = view.videoCategoryButton
        self.selectedCategory = videoItem.category

        if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.videoID))/maxresdefault.jpg") {
            view.videoImageView.downloadImage(from: url)
        } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.videoID))/default.jpg") {
            view.videoImageView.downloadImage(from: url)
        } else {
            view.videoImageView.isHidden = true
        }
        
        view.videoCategoryButton.addTarget(self, action: #selector(showCategories), for: .touchUpInside)
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: true)
        malert.buttonsAxis = .vertical
        malert.buttonsSpace = 10
        malert.buttonsSideMargin = 20
        malert.buttonsBottomMargin = 20
        malert.cornerRadius = 10
        malert.separetorColor = .clear
        malert.animationType = .fadeIn
        malert.presentDuration = 1.0
        
        let cancelButton = MalertAction(title: "취소") {}

        cancelButton.cornerRadius = 10
        cancelButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        cancelButton.tintColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.borderColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.borderWidth = 1
        
        let deleteButton = MalertAction(title: "삭제") {
            let documentReference = self.database.collection(self.userID).document("video_" + videoItem.videoID)
            documentReference.delete { error in
                guard error == nil else { return }
                
                NotificationPresenter.shared.present("동영상을 삭제했습니다", includedStyle: .success)
                
                var videoOrder = Manager.shared.getVideoOrderList()
                videoOrder.removeAll { videoID in
                    videoID == videoItem.videoID
                }
                
                let videoOrderReference = self.database.collection(self.userID).document("videoOrder")
                videoOrderReference.updateData(["order": videoOrder]) { error in
                    guard error == nil else { return }
                    
                    Manager.shared.setVideoOrderList(videoOrderList: videoOrder)
                    let configurationsReference = self.database.collection(self.userID).document("configurations")
                    configurationsReference.updateData(["lastCategoryIndex": self.category!])
                    
                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
                }

            }
           
        }
        
        deleteButton.cornerRadius = 10
        deleteButton.backgroundColor = .systemPink
        deleteButton.tintColor = .white
    
        let completeButton = MalertAction(title: "수정") {
            var dict: [String: Any] = [:]
            dict["category"] = view.videoCategoryButton.titleLabel?.text ?? ""
            dict["videoID"] = videoItem.videoID
            dict["title"] = view.videoTitleTextField.text ?? ""
            dict["liked"] = videoItem.liked
            dict["time"] = videoItem.time

            self.database.collection(self.userID).document("video_" + videoItem.videoID).setData(dict)
            let configurationsReference = self.database.collection(self.userID).document("configurations")
            configurationsReference.updateData(["lastCategoryIndex": self.category!])
            
            NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        completeButton.tintColor = .white
        
        malert.addAction(cancelButton)
        malert.addAction(deleteButton)
        malert.addAction(completeButton)
    
        DispatchQueue.main.async {
            self.present(malert, animated: true, completion: nil)
        }
    }
    
    @objc func showCategories() {
        DispatchQueue.main.async {
            let selectCategoryVC = SelectCategoryViewController(nibName: "SelectCategoryViewController", bundle: Bundle.main)
            
            selectCategoryVC.receiveItem(selectedCategory: self.selectedCategory) { newCategory in
                self.selectedCategory = newCategory
            }
            self.presentedViewController?.present(selectCategoryVC, animated: true)
//            self.present(selectCategoryVC, animated: true)
        }
    }
}
