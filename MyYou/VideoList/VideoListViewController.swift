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
    var category: String!
    var videos: [VideoItem]! = []
    var videocurrent : [VideoItem]! = []
    let userID = Manager.shared.getUserID()
    private var doubleTapGesture: UITapGestureRecognizer!
    let blackView = UIView()
    var popupView = UIView()

    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var categoryButton: UIButton!
    
    var selectedCategory: String! {
        didSet {
            categoryButton.layer.borderWidth = 0.5
            categoryButton.layer.borderColor = UIColor.gray.cgColor
            categoryButton.layer.cornerRadius = 10
            selectedCategory.isEmpty ? categoryButton.setTitle("------ ⌄", for: .normal) : categoryButton.setTitle(selectedCategory + " ⌄", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = " "
        self.loadVideos()
    }
    
    public func receiveCategory(category: String) -> UIViewController {
        self.category = category
        return self
    }
    
    func loadVideos() {
        let userID = Manager.shared.getUserID()
        let params: Parameters = ["userID" : userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable/get_videos.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: VideoItemList.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let videoItemList = response.value else { return }
                
                let filteredVideos = videoItemList.product.filter { videoItem in
                    if self.category == "전체영상" {
                        return true
                    } else {
                        return videoItem.category == self.category
                    }
                }
                
                self.videos = filteredVideos
                self.reorderVideos()
                DispatchQueue.main.async {
                    self.emptyLabel.isHidden = !self.videos.isEmpty
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
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
            videocurrent = [videoItem]
            self.showVideoEdit(videoItem: videoItem)
        }
    }
    
    func showVideoEdit(videoItem: VideoItem) {
        popupView = {
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
            
            view.videoCategoryButton.layer.borderWidth = 0.5
            view.videoCategoryButton.addTarget(self, action: #selector(showCategories), for: .touchUpInside)
            view.videoAddButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
            view.videoDeleteButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#DC5C60")
            view.videoAddButton.layer.cornerRadius = 10
            view.videoDeleteButton.layer.cornerRadius = 10
            view.videoAddButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
            view.videoDeleteButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
            view.cancelImage.isUserInteractionEnabled = true
            view.cancelImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            return view
        }()
        
        if let window = UIApplication.shared.keyWindow {
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(self.blackView)
            window.addSubview(popupView)
            
            let height: CGFloat = window.frame.height*5/6
            let y = window.frame.height - height
            popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
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
            if let window = UIApplication.shared.keyWindow {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
        }
    }
    
    
    
    func showVideoEdit2(videoItem: VideoItem) {
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
        //view.cancelButton.addTarget(self, action: #selector(showDismiss), for: .touchUpInside)
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: true)
        
        malert.buttonsAxis = .vertical
        malert.buttonsSpace = 10
        malert.buttonsSideMargin = 20
        malert.buttonsBottomMargin = 20
        malert.cornerRadius = 10
        malert.separetorColor = .clear
        malert.animationType = .fadeIn
        
        malert.presentDuration = 1.0
        
 /*       let cancelButton = MalertAction(title: "취소") {}

        cancelButton.cornerRadius = 10
        cancelButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        cancelButton.tintColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.borderColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.borderWidth = 1 */
        
        let deleteButton = MalertAction(title: "삭제") {
//            let documentReference = self.database.collection(self.userID).document("video_" + videoItem.videoID)
//            documentReference.delete { error in
//                guard error == nil else { return }
//                
//                NotificationPresenter.shared.present("동영상을 삭제했습니다", includedStyle: .success)
//                
//                var videoOrder = Manager.shared.getVideoOrderList()
//                videoOrder.removeAll { videoID in
//                    videoID == videoItem.videoID
//                }
//                
//                let videoOrderReference = self.database.collection(self.userID).document("videoOrder")
//                videoOrderReference.updateData(["order": videoOrder]) { error in
//                    guard error == nil else { return }
//                    
//                    Manager.shared.setVideoOrderList(videoOrderList: videoOrder)
//                    let configurationsReference = self.database.collection(self.userID).document("configurations")
//                    configurationsReference.updateData(["lastCategoryIndex": self.category!])
//                    
//                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
//                }
//
//            }
           
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
            
            if view.videoCategoryButton.titleLabel?.text == "------" {
                let alert = UIAlertController(title: "", message: "동영상을 수정할 수 없습니다. 카테고리 제목을 다시 확인해주시기 바랍니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                DispatchQueue.main.async{
                    self.present(alert, animated: true)
                }
            } else {
//                self.database.collection(self.userID).document("video_" + videoItem.videoID).setData(dict)
//                let configurationsReference = self.database.collection(self.userID).document("configurations")
//                configurationsReference.updateData(["lastCategoryIndex": self.category!])
//                
//                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
            }

//            self.database.collection(self.userID).document("video_" + videoItem.videoID).setData(dict)
//            let configurationsReference = self.database.collection(self.userID).document("configurations")
//            configurationsReference.updateData(["lastCategoryIndex": self.category!])
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor.purple
        completeButton.tintColor = .white
        malert.addAction(completeButton)
        malert.addAction(deleteButton)
        
        DispatchQueue.main.async {
            self.present(malert, animated: true, completion: nil)
        }
    }
    
    @objc func deleteItem() {
//        let item = videocurrent[0]
//        let documentReference = self.database.collection(self.userID).document("video_" + item.videoID)
//        documentReference.delete { error in
//            guard error == nil else { return }
//            
//            NotificationPresenter.shared.present("동영상을 삭제했습니다", includedStyle: .success)
//            
//            var videoOrder = Manager.shared.getVideoOrderList()
//            videoOrder.removeAll { videoID in
//                videoID == item.videoID
//            }
//            
//            let videoOrderReference = self.database.collection(self.userID).document("videoOrder")
//            videoOrderReference.updateData(["order": videoOrder]) { error in
//                guard error == nil else { return }
//                
//                Manager.shared.setVideoOrderList(videoOrderList: videoOrder)
//                let configurationsReference = self.database.collection(self.userID).document("configurations")
//                configurationsReference.updateData(["lastCategoryIndex": self.category!])
//                
//                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
//            }
//            self.handleDismiss()
//        }
        
    }
    
    @objc func addItem() {
     /*   let item = videocurrent[0]
        var dict: [String: Any] = [:]
        dict["category"] = self.videoCategoryButton.titleLabel?.text ?? ""
        dict["videoID"] = item.videoID
        dict["title"] = self.videoTitleTextField.text ?? ""
        dict["liked"] = item.liked
        dict["time"] = item.time
        
        if view.videoCategoryButton.titleLabel?.text == "------" {
            let alert = UIAlertController(title: "", message: "동영상을 수정할 수 없습니다. 카테고리 제목을 다시 확인해주시기 바랍니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            DispatchQueue.main.async{
                self.present(alert, animated: true)
            }
        } else {
            self.database.collection(self.userID).document("video_" + item.videoID).setData(dict)
            let configurationsReference = self.database.collection(self.userID).document("configurations")
            configurationsReference.updateData(["lastCategoryIndex": self.category!])
>>>>>>> Stashed changes
            
            NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
        } */

    }
    
    @objc func showCategories() {
        DispatchQueue.main.async {
            let selectCategoryVC = SelectCategoryViewController(nibName: "SelectCategoryViewController", bundle: Bundle.main)
            
            selectCategoryVC.receiveItem(selectedCategory: self.selectedCategory) { newCategory in
                self.selectedCategory = newCategory
            }
            
            selectCategoryVC.transitioningDelegate = self
            selectCategoryVC.modalPresentationStyle = .custom
            self.presentedViewController?.present(selectCategoryVC, animated: true)
            self.present(selectCategoryVC, animated: true)
        }
    }
    
    func reorderVideos() {
        let videoOrderList = Manager.shared.getVideoOrderList()
        var orderedVideoList: [VideoItem] = []
        let videoItemIds: [String] = self.videos.map { videoItem in
            videoItem.videoID
        }
        
        for videoOrder in videoOrderList {
            if let index = videoItemIds.firstIndex(of: videoOrder) {
                orderedVideoList.append(self.videos[index])
            }
            
            if orderedVideoList.count == self.videos.count {
                break
            }
        }
        
        self.videos = orderedVideoList
        
        DispatchQueue.main.async {
            self.setCollectionView()
//            self.presentedViewController?.present(selectCategoryVC, animated: true)
//            self.present(selectCategoryVC, animated: true)
            //let smallVC = self.storyboard!.instantiateViewController(withIdentifier: "SelectCategoryViewController")
            
            
//            
//            self.present(selectCategoryVC, animated: true, completion:  nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //if segue.destination is YourViewController {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        //}
    }
}

extension VideoListViewController: BonsaiControllerDelegate {
    
    // return the frame of your Bonsai View Controller
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 30, y: containerViewFrame.height / 6), size: CGSize(width: containerViewFrame.width-60, height: containerViewFrame.height * (2/3) - 100 ))
    }
    
    // return a Bonsai Controller with SlideIn or Bubble transition animator
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        /// With Background Color ///
        
        // Slide animation from .left, .right, .top, .bottom
        //return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.5), presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, backgroundColor: UIColor(white: 0, alpha: 0.5), presentedViewController: presented, delegate: self)
        
        
        /// With Blur Style ///
        
        // Slide animation from .left, .right, .top, .bottom
        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .dark, presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, blurEffectStyle: .dark,  presentedViewController: presented, delegate: self)
    }
}
