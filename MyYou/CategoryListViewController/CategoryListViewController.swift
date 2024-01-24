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

class CategoryListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyCategoryLabel: UILabel!
    var categories: [Category] = Manager2.shared.user.categories
    var videoCategories: [Category]!
    
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
        
        self.videoCategories = self.categories.filter({ category in
            category.categoryName != "전체영상" && category.categoryName != "설정"
        })

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
        
        self.emptyCategoryLabel.isHidden = !self.videoCategories.isEmpty
    }
    
    func addRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addCategory(sender:)))
    }
    
    @objc func addCategory(sender: UIBarButtonItem) {
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
            Manager2.shared.user.categories.insert(newCategory, at: 0)
            
            if let firstItem = Manager2.shared.user.categoryIDs.first, firstItem.isEmpty {
                Manager2.shared.user.categoryIDs[0] = newCategory.categoryID
            } else {
                Manager2.shared.user.categoryIDs.insert(newCategory.categoryID, at: 0)
            }
            
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
    }
    
    func editCategory(category: Category) {
        let view = CategoryAlertView.instantiateFromNib()
        view.categoryTextField.text = category.categoryName
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: false)
        malert.buttonsAxis = .vertical
        malert.buttonsSpace = 10
        malert.buttonsSideMargin = 20
        malert.buttonsBottomMargin = 20
        malert.cornerRadius = 10
        malert.separetorColor = .clear
        malert.animationType = .fadeIn
        malert.presentDuration = 1.0
        
        let cancelButton = MalertAction(title: "취소") {
            malert.dismiss(animated: true)
        }

        cancelButton.cornerRadius = 10
        cancelButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        cancelButton.tintColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.borderColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.borderWidth = 1
        
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
            
            if self.videoCategories.contains(where: { category in
                category.categoryName == newCategoryName
            }) {
                NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error)
                return
            }
            
            self.updateCategoryName(category: category, newCategoryName: newCategoryName)
            malert.dismiss(animated: true)
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        completeButton.tintColor = .white
        
        malert.addAction(cancelButton)
        malert.addAction(deleteButton)
        
        if category.isOwner() {
            malert.addAction(completeButton)            
        }
    
        DispatchQueue.main.async {
            self.present(malert, animated: true, completion: nil)
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
        self.videoCategories = self.categories.filter({ category in
            category.categoryName != "전체영상" && category.categoryName != "설정"
        })
        self.collectionView.reloadData()
        self.emptyCategoryLabel.isHidden = !self.videoCategories.isEmpty
    }
}
