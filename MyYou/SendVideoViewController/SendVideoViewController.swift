//
//  SendVideoViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import UIKit
import JDStatusBarNotification
import Alamofire

class SendVideoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var addPhoneButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emptyTextLabel: UILabel!
    
    var phoneNumbers: [String] = []
    let blackView = UIView()
    var popupView = UIView()
    var selectCategoryView: SelectCategoryView?
    var tableViewHeightConstraint: NSLayoutConstraint!
    let categories: [Category] = Manager2.shared.getCategories()
    var observer: NSKeyValueObservation?
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func setupUI() {
        self.title = "카테고리 보내기"
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
        
        self.addPhoneButton.layer.cornerRadius = 10
        self.nextButton.layer.cornerRadius = 10
        self.setCollectionView()
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib(nibName: "SendVideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SendVideoCollectionViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
        layout.minimumLineSpacing = 40
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 50)
        
        self.collectionView.collectionViewLayout = layout
        
        self.emptyTextLabel.isHidden = !self.phoneNumbers.isEmpty
        self.nextButton.isEnabled = !self.phoneNumbers.isEmpty
    }
    
    @IBAction func addPhoneButtonPressed(_ sender: UIButton) {
        guard let phoneNumber = self.phoneTextField.text, !phoneNumber.isEmpty else {
            NotificationPresenter.shared.present("휴대폰 번호를 입력해주세요", includedStyle: .error, duration: 2.0)
            return
        }
        
        self.phoneNumbers.append(phoneNumber)
        self.collectionView.reloadData()
        
        if !self.phoneNumbers.isEmpty {
            self.emptyTextLabel.isHidden = true
            self.nextButton.isEnabled = true
        }
        
        self.phoneTextField.text = ""
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        guard !self.phoneNumbers.isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            let selectCategoryToSendVC = SelectCategoryToSendViewController(nibName: "SelectCategoryToSendViewController", bundle: Bundle.main)
            selectCategoryToSendVC.receiveItem(phoneNumbers: self.phoneNumbers)
            
            self.navigationController?.pushViewController(selectCategoryToSendVC, animated: true)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            if let window = self.view.window {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
        }
    }
    


    @objc func dismissKeyboard() {
        self.phoneTextField.resignFirstResponder()
    }
}
