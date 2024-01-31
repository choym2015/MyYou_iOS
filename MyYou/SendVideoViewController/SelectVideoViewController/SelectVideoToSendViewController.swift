//
//  SelectVideoToSendViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/30/24.
//

import UIKit
import JDStatusBarNotification

class SelectVideoToSendViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var videos: [VideoItem] = []
    var category: Category!
    var phoneNumbers: [String]!
    var shouldSend: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadVideos()
        
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
    }
    
    func receiveItem(phoneNumbers: [String], category: Category) {
        self.phoneNumbers = phoneNumbers
        self.category = category
    }
    
    func loadVideos() {
        self.videos = Manager2.shared.user.videoItems.filter({ videoItem in
            category.videoIDs.contains(videoItem.videoID)
        })
        
        for video in videos {
            self.shouldSend.append(video.isOwner())
        }
        
        self.setCollectionView()
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

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        var videoIDsToSend: [String] = []
        
        for (index, value) in self.shouldSend.enumerated() {
            if value {
                let videoItem = self.videos[index]
                videoIDsToSend.append(videoItem.videoID)
            }
        }
        
        var messageIDs: [String] = []
        for phoneNumber in phoneNumbers {
            let messageID = UUID().uuidString
            messageIDs.append(messageID)
        }
        
        
        NetworkManager.createMessage(phoneNumbers: phoneNumbers, videoIDs: videoIDsToSend, messageIDs: messageIDs, category: category) { response in
            switch response.result {
            case .success:
                for (index, phoneNumber) in self.phoneNumbers.enumerated() {
                    let messageID = messageIDs[index]
                    
                    NetworkManager.postFirebasePush(phoneNumber: phoneNumber, category: self.category, messageID: messageID)
                }
                
                DispatchQueue.main.async {
                    NotificationPresenter.shared.present("카테고리 보내기 성공", includedStyle: .success, duration: 2.0)
                    self.navigationController?.popToRootViewController(animated: true)
                }

            case .failure(let error):
                NotificationPresenter.shared.present(error.localizedDescription, includedStyle: .error, duration: 2.0)
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
