//
//  CategoryListViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import UIKit
import Malert
import JDStatusBarNotification
import Alamofire

class CategoryListViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyCategoryLabel: UILabel!
    
    var blackView = UIView()
    var popupView: UIView!
    
    var categories: [Category] = Manager2.shared.user.categories
    
    var selectedCategory: Category?
    var categoryTextField: UITextField?
    var completeButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "카테고리 수정"
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.setCollectionView()
        self.addRightButton()
    }
    
    private func setCollectionView() {
        self.collectionView.register(UINib(nibName: "CategoryListViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CategoryListViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self
        self.collectionView.backgroundColor = UIColor().hexStringToUIColor(hex: "#eef1f6")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
        layout.minimumLineSpacing = 40
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 50)
        
        self.collectionView.collectionViewLayout = layout
        
        self.emptyCategoryLabel.isHidden = !self.categories.isEmpty
    }
    
    func addRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addCategory(sender:)))
    }
    
    @objc func addCategory(sender: UIBarButtonItem) {
        self.popupView = {
            let view = CategoryListAddView.instantiateFromNib()
            view.categoryTextField.delegate = self
            self.categoryTextField = view.categoryTextField
            self.completeButton = view.completeButton
            view.titleLabel.text = "카테고리 추가"
            view.cancelButton.addTarget(self, action: #selector(self.handleDismiss), for: .touchUpInside)
            view.completeButton.layer.cornerRadius = 10
            view.completeButton.setTitle("추가", for: .normal)
            view.completeButton.isEnabled = false
            view.completeButton.backgroundColor = .cancel
            
            view.completeButton.addTarget(self, action: #selector(self.addCategoryButtonPressed), for: .touchUpInside)
        
            return view
        }()
        
        if let window = self.view.window {
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            window.addSubview(popupView)
            
            let height: CGFloat = 260
            let y = window.frame.height - height
            self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            self.blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.popupView.frame = CGRect(x: 0, y: y, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func addCategoryButtonPressed() {
        guard let categoryTextField = self.categoryTextField,
                let newCategoryName = categoryTextField.text else { return }
        
        guard !newCategoryName.isEmpty else {
            NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error, duration: 2.0)
            return
        }
        
        guard self.categories.filter({ category in
            category.categoryName == newCategoryName
        }).isEmpty else {
            NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error, duration: 2.0)
            return
        }
        
        let newCategory = Category(categoryID: UUID().uuidString, ownerID: Manager2.shared.getUserID(), referenceCategoryID: "", categoryName: newCategoryName, videoIDs: [])
        
        Manager2.shared.user.categories.insert(newCategory, at: 1)
        Manager2.shared.user.categoryIDs.insert(newCategory.categoryID, at: 1)
        
        categoryTextField.resignFirstResponder()
        
        NetworkManager.createCategory(newCategory: newCategory) { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                        self.handleDismiss()
                    }
                    
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error, duration: 2.0)
                self.handleDismiss()
            }
        }
    }
    
    func editCategory(category: Category) {
        self.popupView = {
            let view = CategoryAlertView.instantiateFromNib()
            self.selectedCategory = category
            self.categoryTextField = view.categoryTextField
            self.completeButton = view.completeButton
            view.categoryTextField.text = category.categoryName
            view.categoryTextField.delegate = self
            view.cancelButton.addTarget(self, action: #selector(self.handleDismiss), for: .touchUpInside)
            view.completeButton.layer.cornerRadius = 10
            view.deleteButton.layer.cornerRadius = 10
            view.completeButton.addTarget(self, action: #selector(self.changeCategory), for: .touchUpInside)
            view.deleteButton.addTarget(self, action: #selector(self.deleteCategory), for: .touchUpInside)
            
            return view
        }()
        
        if let window = self.view.window {
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            window.addSubview(popupView)
            
            let height: CGFloat = 300
            let y = window.frame.height - height
            self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            self.blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.popupView.frame = CGRect(x: 0, y: y, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.popupView.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.popupView.frame.origin.y += keyboardSize.height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let completeButton = self.completeButton else { return }
        
        if let text = textField.text,
           !text.isEmpty {
            completeButton.isEnabled = true
            completeButton.isUserInteractionEnabled = true
            completeButton.backgroundColor = .colorPrimary
        } else {
            completeButton.isEnabled = false
            completeButton.isUserInteractionEnabled = false
            completeButton.backgroundColor = .cancel
        }
    }
    
    @objc func changeCategory() {
        guard let categoryTextField = self.categoryTextField,
              let newCategoryName = categoryTextField.text,
              let selectedCategory = self.selectedCategory else { return }
        
        guard !newCategoryName.isEmpty else {
            NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error, duration: 2.0)
            return
        }
        
        guard self.categories.filter({ category in
            category.categoryName == newCategoryName
        }).isEmpty else {
            NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error, duration: 2.0)
            return
        }
        
        categoryTextField.resignFirstResponder()
        
        NetworkManager.updateCategoryName(oldCategory: selectedCategory, newCategoryName: newCategoryName) { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                        self.handleDismiss()
                    }
                    
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error, duration: 2.0)
                self.handleDismiss()
            }
        }
    }
    
    @objc func deleteCategory() {
        guard let selectedCategory = self.selectedCategory,
              let index = Manager2.shared.user.categoryIDs.firstIndex(of: selectedCategory.categoryID) else { return }
        
        Manager2.shared.user.categoryIDs.remove(at: index)
        
        NetworkManager.deleteCategory(category: selectedCategory) { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                        self.handleDismiss()
                    }
                    
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error, duration: 2.0)
                self.handleDismiss()
            }
        }
    }
    
    @objc func handleDismiss() {
        self.categoryTextField?.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5) {
            
            self.blackView.alpha = 0
            if let window = self.view.window {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
        }
    }
    

//    
//    func deleteCategoryOwner(category: Category, categoryIDs: [String]) {
//        let params: Parameters = ["categoryID" : category.categoryID,
//                                  "categoryName" : category.categoryName,
//                                  "categoryIDs" : categoryIDs.joined(separator: ","),
//                                  "ownerID" : category.ownerID,
//                                  "userID" : Manager2.shared.getUserID()]
//        
//        AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/delete_category_owner.php/",
//                   method: .post,
//                   parameters: params,
//                   encoding: URLEncoding.default,
//                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
//        
//        .validate(statusCode: 200..<300)
//        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
//            switch response.result {
//            case .success:
//                DispatchQueue.main.async {
//                    HomeViewController.reload {
//                        self.updateVideoCategories()
//                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
//                    }
//                }
//            case .failure(let err):
//                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
//            }
//        })
//    }
    
    func deleteCategoryAudience(category: Category, categoryIDs: [String]) {
//        var audienceIDs = category.audienceID.components(separatedBy: ",")
//        
//        guard let index = audienceIDs.firstIndex(of: Manager2.shared.getUserID()) else { return }
//        audienceIDs.remove(at: index)
//        
//        let params: Parameters = ["categoryID" : category.categoryID,
//                                  "categoryName" : category.categoryName,
//                                  "categoryIDs" : categoryIDs.joined(separator: ","),
//                                  "audienceIDs" : audienceIDs.joined(separator: ","),
//                                  "userID" : Manager2.shared.getUserID()]
//        
//        AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/delete_category_audience.php/",
//                   method: .post,
//                   parameters: params,
//                   encoding: URLEncoding.default,
//                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
//        
//        .validate(statusCode: 200..<300)
//        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
//            switch response.result {
//            case .success:
//                DispatchQueue.main.async {
//                    HomeViewController.reload {
//                        self.updateVideoCategories()
//                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
//                    }
//                }
//            case .failure(let err):
//                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
//            }
//        })
    }
    
    func updateVideoCategories() {
        self.categories = Manager2.shared.user.categories
        self.collectionView.reloadData()
        self.emptyCategoryLabel.isHidden = !self.categories.isEmpty
    }
}
