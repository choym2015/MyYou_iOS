//
//  VideoListViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import UIKit

class VideoListViewController: UIViewController {
    var category: String!
    var videos: [VideoItem]! = []
    let database = Manager.shared.getDB()
    let userID = Manager.shared.getUserID()

    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
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
    }
}
