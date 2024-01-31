//
//  VideoListViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import UIKit
import Malert
import JDStatusBarNotification
import Alamofire
import BonsaiController

class VideoListViewController: UIViewController {    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    let blackView = UIView()
    var popupView: UIView!
    var textHeightConstraint: NSLayoutConstraint!

    var category: Category!
    var videos: [VideoItem] = []
    var selectedVideo: VideoItem?
    var editVideoView: VideoEditView?
    var needsReload: Bool = false
    var doubleTapGesture: UITapGestureRecognizer!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = " "
        self.loadVideos()
    }
    
    public func receiveCategory(category: Category) -> UIViewController {
        self.category = category
        return self
    }
    
    func loadVideos() {
        self.videos = Manager2.shared.user.videoItems.filter({ videoItem in
            self.category.videoIDs.contains(videoItem.videoID)
        })
        
        DispatchQueue.main.async {
            self.emptyLabel.isHidden = !self.videos.isEmpty
            self.setCollectionView()
        }
    }
 
    private func setCollectionView() {
        self.collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoCollectionViewCell")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.dragInteractionEnabled = true
        self.collectionView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 30
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 500)
        
        self.collectionView.collectionViewLayout = layout
        self.setUpDoubleTap()
        
        self.refreshControl.addTarget(self, action: #selector(self.didPullToRefresh(_:)), for: .valueChanged)
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.refreshControl = self.refreshControl
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
        self.popupView = {
            self.selectedVideo = videoItem
            
            self.editVideoView = VideoEditView.instantiateFromNib()
            self.editVideoView?.titleTextView.text = videoItem.title.decodeUrl()
            self.editVideoView?.titleTextView.delegate = self
            self.editVideoView?.titleTextView.isUserInteractionEnabled = videoItem.isOwner()

            self.textHeightConstraint = self.editVideoView?.titleTextView.heightAnchor.constraint(equalToConstant: 40)
            self.textHeightConstraint.isActive = true
            self.adjustTextViewHeight(textView: self.editVideoView!.titleTextView)

            self.editVideoView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

            if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.youtubeID))/maxresdefault.jpg") {
                self.editVideoView?.videoImageView.downloadImage(from: url)
            } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.youtubeID))/default.jpg") {
                self.editVideoView?.videoImageView.downloadImage(from: url)
            } else {
                self.editVideoView?.videoImageView.isHidden = true
            }
            
            if self.category.categoryName == "임시" && !Manager2.shared.user.lastCategoryID.isEmpty {
                if let lastCategory = Helper.getCategoryForCategoryID(categoryID: Manager2.shared.user.lastCategoryID),
                   lastCategory.isOwner() {
                    self.editVideoView?.videoCategoryButton.setTitle(lastCategory.categoryName, for: .normal)
                } else {
                    self.editVideoView?.videoCategoryButton.setTitle(category.categoryName, for: .normal)
                }
            } else {
                self.editVideoView?.videoCategoryButton.setTitle(category.categoryName, for: .normal)
            }
            
            self.editVideoView?.videoCategoryButton.layer.borderWidth = 0.5
            self.editVideoView?.videoCategoryButton.addTarget(self, action: #selector(self.showCategories), for: .touchUpInside)
            self.editVideoView?.videoCategoryButton.layer.cornerRadius = 10
            
            self.editVideoView?.videoEditButton.layer.cornerRadius = 10
            self.editVideoView?.videoEditButton.addTarget(self, action: #selector(self.editItem), for: .touchUpInside)
            
            self.editVideoView?.videoDeleteButton.layer.cornerRadius = 10
            self.editVideoView?.videoDeleteButton.addTarget(self, action: #selector(self.deleteItem), for: .touchUpInside)
            
            self.editVideoView?.cancelImage.isUserInteractionEnabled = true
            self.editVideoView?.cancelImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            return editVideoView!
        }()
        
        if let window = self.view.window {
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(self.blackView)
            window.addSubview(self.popupView)
            
            let newHeight = 650 - 42.67 + self.textHeightConstraint.constant
            self.editVideoView?.heightConstraint.constant = newHeight
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
                HomeViewController.reload {
                    NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)              
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        if self.editVideoView?.titleTextView.isFirstResponder != nil {
            self.editVideoView?.titleTextView.resignFirstResponder()
        }
    }
    
    @objc func deleteItem() {
        self.needsReload = true
        
        guard var videoItem = self.selectedVideo else { return }
        
        self.category.removeVideoID(videoID: videoItem.videoID)
        
        Manager2.shared.user.lastCategoryID = self.category.categoryID
        NetworkManager.updateLastCategory(lastCategoryID: self.category.categoryID)

        NetworkManager.deleteVideo(videoItem: videoItem, category: self.category) { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    self.handleDismiss()
                }
            case .failure:
                NotificationPresenter.shared.present(response.error?.localizedDescription ?? "FAIL", includedStyle: .error, duration: 2.0)
            }
        }
    }
    
    @objc func editItem() {
        self.needsReload = true
        
        guard var videoItem = self.selectedVideo,
              let title = self.editVideoView?.titleTextView.text.encodeUrl(),
              let updatedCategory = Helper.getMyCategory(categoryName: self.editVideoView?.videoCategoryButton.titleLabel?.text) else { return }
        
        updatedCategory.addVideoID(videoID: videoItem.videoID)
        self.category.removeVideoID(videoID: videoItem.videoID)
        
        Manager2.shared.user.lastCategoryID = updatedCategory.categoryID
        NetworkManager.updateLastCategory(lastCategoryID: updatedCategory.categoryID)
    
        videoItem.title = title
        
        NetworkManager.updateVideoCategory(videoItem: videoItem, oldCategory: self.category, newCategory: updatedCategory) { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    self.handleDismiss()
                }
            case .failure:
                NotificationPresenter.shared.present(response.error?.localizedDescription ?? "FAIL", includedStyle: .error, duration: 2.0)
            }
        }
    }
    
    @objc func showCategories() {
        DispatchQueue.main.async {
            let selectCategoryVC = SelectCategoryViewController(nibName: "SelectCategoryViewController", bundle: Bundle.main)
            let selectedCategory = Helper.getCategory(categoryName: self.editVideoView?.videoCategoryButton.titleLabel?.text)
            
            selectCategoryVC.receiveItem(selectedCategory: selectedCategory) { newCategory, updateRequired in
                self.needsReload = updateRequired
                guard let categoryButton = self.editVideoView?.videoCategoryButton else { return }

                if let selectedCategory = newCategory {
                    categoryButton.setTitle(selectedCategory.categoryName, for: .normal)
                }
            }
            
            selectCategoryVC.transitioningDelegate = self
            selectCategoryVC.modalPresentationStyle = .custom
            self.present(selectCategoryVC, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.transitioningDelegate = self
        segue.destination.modalPresentationStyle = .custom
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        HomeViewController.reload {
            self.videos = Manager2.shared.user.videoItems.filter({ videoItem in
                self.category.videoIDs.contains(videoItem.videoID)
            })
            
            DispatchQueue.main.async {
                self.emptyLabel.isHidden = !self.videos.isEmpty
                self.collectionView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
    }
}

extension VideoListViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 30, y: containerViewFrame.height / 6), size: CGSize(width: containerViewFrame.width-60, height: containerViewFrame.height * (2/3) - 100 ))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .dark, presentedViewController: presented, delegate: self)
    }
}
