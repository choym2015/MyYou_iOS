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
    var categories: [Category] = Manager2.shared.user.categories
//    var videoCategories: [Category]!
    var blackView = UIView()
    var popupView = UIView()
    var selectedCategoryName = ""
    
    var selectedCategory: [Category]!
    
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
        
//        self.videoCategories = self.categories.filter({ category in
//            category.categoryName != "전체영상" && category.categoryName != "설정"
//        })

        self.setCollectionView()
        self.addRightButton()
    }
    
    private func setCollectionView() {
        self.collectionView.register(UINib(nibName: "CategoryListViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CategoryListViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
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
            view.titleLabel.text = "카테고리 추가"
            view.cancelButton.addTarget(self, action: #selector(self.handleDismiss), for: .touchUpInside)
            view.completeButton.layer.cornerRadius = 10
            view.completeButton.setTitle("카테고리 추가", for: .normal)
            
            view.completeButton.addTarget(self, action: #selector(self.changeCategory), for: .touchUpInside)
        
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
        
        /*
        let view = CategoryAlertView.instantiateFromNib()
        view.categoryTextField.becomeFirstResponder()
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: false)
        malert.buttonsAxis = .horizontal
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
    
        let completeButton = MalertAction(title: "확인") {
            guard let categoryName = view.categoryTextField.text, !categoryName.isEmpty else {
                NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error)
                return
            }
            
            if Helper.getCategory(categoryName: categoryName) != nil {
                NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error)
                return
            }
            
            let newCategory = Category(categoryID: UUID().uuidString, ownerID: Manager2.shared.getUserID(), audienceID: "", categoryName: categoryName)
            Manager2.shared.user.categories.insert(newCategory, at: 1)
            Manager2.shared.user.categoryIDs.insert(newCategory.categoryID, at: 1)
            
            let listString = Manager2.shared.user.categoryIDs.joined(separator: ",")
            
            let params: Parameters = [
                "userID" : Manager2.shared.getUserID(),
                "ownerID" : newCategory.ownerID,
                "audienceID" : "",
                "categoryName" : newCategory.categoryName,
                "categoryID" : newCategory.categoryID,
                "categoryIDs" : listString
            ]
            
            AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/create_category.php/",
                       method: .post,
                       parameters: params,
                       encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
            
            .validate(statusCode: 200..<300)
            .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        HomeViewController.reload {
                            self.updateVideoCategories()
                            NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                            malert.dismiss(animated: true)
                        }
                        
                    }
                case .failure(let err):
                    NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
                    malert.dismiss(animated: true)
                }
            })
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        completeButton.tintColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        
        malert.addAction(cancelButton)
        malert.addAction(completeButton)
    
        DispatchQueue.main.async {
            self.present(malert, animated: true, completion: nil)
        }
         */
    }
    
    func editCategory(category: Category) {
        self.popupView = {
            let view = CategoryAlertView.instantiateFromNib()
            //        selectedCategoryName = category.categoryName
            view.categoryTextField.text = category.categoryName
            view.categoryTextField.delegate = self
            view.cancelButton.addTarget(self, action: #selector(self.handleDismiss), for: .touchUpInside)
            view.completeButton.layer.cornerRadius = 10
            view.deleteButton.layer.cornerRadius = 10
            //         selectedCategory[0] = category
            view.completeButton.addTarget(self, action: #selector(self.changeCategory), for: .touchUpInside)
            view.deleteButton.addTarget(self, action: #selector(self.deleteSelected), for: .touchUpInside)
            
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
        
        /*
        let view = CategoryAlertView.instantiateFromNib()
        view.categoryTextField.text = category.categoryName
        view.cancelButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: false)
        malert.buttonsAxis = .vertical
        malert.buttonsSpace = 10
        malert.buttonsSideMargin = 20
        malert.buttonsBottomMargin = 20
        malert.cornerRadius = 10
        malert.separetorColor = .clear
        malert.animationType = .fadeIn
        malert.presentDuration = 1.0

        
        let deleteButton = MalertAction(title: "삭제") {
            var categoryIDs = Manager2.shared.getCategoryIDs()
            categoryIDs.removeAll(where: { categoryID in
                categoryID == category.categoryID
            })
            
            if category.isOwner() {
                if category.audienceID.isEmpty {
                    self.deleteCategory(category: category, categoryIDs: categoryIDs)
                } else {
                    self.deleteCategoryOwner(category: category, categoryIDs: categoryIDs)
                }
            } else {
                self.deleteCategoryAudience(category: category, categoryIDs: categoryIDs)
            }
            
            malert.dismiss(animated: true)
        }
        
        deleteButton.cornerRadius = 10
        deleteButton.backgroundColor = .systemPink
        deleteButton.tintColor = .white
    
        let completeButton = MalertAction(title: "수정") {
            guard let newCategoryName = view.categoryTextField.text else {
                NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error)
                return
            }
            
            view.categoryTextField.resignFirstResponder()
            
            if Helper.getCategory(categoryName: newCategoryName) != nil {
                NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error)
                return
            }
            
            self.updateCategoryName(category: category, newCategoryName: newCategoryName)
            malert.dismiss(animated: true)
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        completeButton.tintColor = .white
        
        if category.isOwner() {
            malert.addAction(completeButton)            
        }
        malert.addAction(deleteButton)
         */
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
    
    @objc func changeCategory() {
        let newCategoryName = selectedCategory[0].categoryName
        
        //view.categoryTextField.resignFirstResponder()
        
        if Helper.getCategory(categoryName: newCategoryName) != nil {
            NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error)
            return
        }
        
        self.updateCategoryName(category: selectedCategory[0], newCategoryName: newCategoryName)
        
        UIView.animate(withDuration: 0.5) {
            
            self.blackView.alpha = 0
            if let window = self.view.window {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
        }
    }
    
    @objc func deleteSelected() {
        let category = selectedCategory[0]
        var categoryIDs = Manager2.shared.getCategoryIDs()
        categoryIDs.removeAll(where: { categoryID in
            categoryID == category.categoryID
        })
        
        if category.isOwner() {
            if category.audienceID.isEmpty {
                self.deleteCategory(category: category, categoryIDs: categoryIDs)
            } else {
                self.deleteCategoryOwner(category: category, categoryIDs: categoryIDs)
            }
        } else {
            self.deleteCategoryAudience(category: category, categoryIDs: categoryIDs)
        }
        
        UIView.animate(withDuration: 0.5) {
            
            self.blackView.alpha = 0
            if let window = self.view.window {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }
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
    
    func deleteCategory(category: Category, categoryIDs: [String]) {
        let params: Parameters = ["categoryID" : category.categoryID,
                                  "categoryName" : category.categoryName,
                                  "categoryIDs" : categoryIDs.joined(separator: ","),
                                  "ownerID" : Manager2.shared.getUserID()]

        AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/delete_category.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                    }
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
            }
        })
    }
    
    func deleteCategoryOwner(category: Category, categoryIDs: [String]) {
        let params: Parameters = ["categoryID" : category.categoryID,
                                  "categoryName" : category.categoryName,
                                  "categoryIDs" : categoryIDs.joined(separator: ","),
                                  "ownerID" : category.ownerID,
                                  "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/delete_category_owner.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                    }
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
            }
        })
    }
    
    func deleteCategoryAudience(category: Category, categoryIDs: [String]) {
        var audienceIDs = category.audienceID.components(separatedBy: ",")
        
        guard let index = audienceIDs.firstIndex(of: Manager2.shared.getUserID()) else { return }
        audienceIDs.remove(at: index)
        
        let params: Parameters = ["categoryID" : category.categoryID,
                                  "categoryName" : category.categoryName,
                                  "categoryIDs" : categoryIDs.joined(separator: ","),
                                  "audienceIDs" : audienceIDs.joined(separator: ","),
                                  "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/delete_category_audience.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                    }
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
            }
        })
    }
    
    func updateCategoryName(category: Category, newCategoryName: String) {
        let params: Parameters = ["categoryID" : category.categoryID,
                                  "oldCategoryName" : category.categoryName,
                                  "newCategoryName" : newCategoryName]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable2/update_category_name.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    HomeViewController.reload {
                        self.updateVideoCategories()
                        NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                    }
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
            }
        })
    }
    
    func updateVideoCategories() {
        self.categories = Manager2.shared.user.categories
//        self.videoCategories = self.categories.filter({ category in
//            category.categoryName != "전체영상" && category.categoryName != "설정"
//        })
        self.collectionView.reloadData()
        self.emptyCategoryLabel.isHidden = !self.categories.isEmpty
    }
}
