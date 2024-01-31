//
//  MessageListViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import UIKit
import Alamofire

class MessageListViewController: UIViewController {
    
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var messages: [MessageItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "받은 카테고리 리스트"
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
        
        if Manager2.shared.user.newMessage {
            NetworkManager.updateNewMessage(newMessage: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadMessages()
    }
    
    func loadMessages() {
        self.messages.removeAll()
        
        let params: Parameters = ["userPhoneNumber" : Manager2.shared.getUserPhoneNumber()]
        
        AF.request("https://chopas.com/smartappbook/myyou/messageTable3/get_messages.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: MessageItemList.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let messageItems = response.value?.product else { return }
                self.messages = messageItems
                
                DispatchQueue.main.async {
                    self.setCollectionView()
                }
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib(nibName: "MessageItemCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MessageItemCollectionViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
        layout.minimumLineSpacing = 40
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 50)
        
        self.collectionView.collectionViewLayout = layout
        
        self.emptyMessageLabel.isHidden = !self.messages.isEmpty
    }
}
