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
    @IBOutlet weak var categoryTableView: UITableView!
    
    let userID = Manager.shared.getUserID()
    var categories: [String] = Manager.shared.getCategories()
    var videoCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryTableView.register(UINib(nibName: "CategoryListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CategoryListTableViewCell")
        
        self.videoCategories = self.categories
        self.videoCategories.removeAll { category in
            category == "전체영상" || category == "설정"
        }
        
        self.categoryTableView.dataSource = self
        self.categoryTableView.delegate = self
        self.categoryTableView.dragInteractionEnabled = true
        self.categoryTableView.dragDelegate = self
        
        self.addRightButton()
    }
    
    func addRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addCategory(sender:)))
    }
    
    @objc func addCategory(sender: UIBarButtonItem) {
        let view = CategoryAlertView.instantiateFromNib()
        view.categoryTextField.becomeFirstResponder()
        
        let malert = Malert(title: nil, customView: view, tapToDismiss: true, dismissOnActionTapped: true)
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
            guard let newCategory = view.categoryTextField.text else {
                NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error)
                return
            }
            
            if self.videoCategories.contains(newCategory) {
                return
            }
            
            if let firstCategory = self.categories.first,
               firstCategory == "전체영상" {
                self.categories.insert(newCategory, at: 1)
            } else {
                self.categories.insert(newCategory, at: 0)
            }
            
            self.videoCategories.insert(newCategory, at: 0)
            
            
            let listString = self.categories.joined(separator: ",")
            let params: Parameters = ["categories" : listString, "userID" : self.userID]
            
            AF.request("https://chopas.com/smartappbook/myyou/categoryTable/update_categories.php/",
                       method: .post,
                       parameters: params,
                       encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
            
            .validate(statusCode: 200..<300)
            .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
                switch response.result {
                case .success:
                    Manager.shared.setCategories(categories: self.categories)
                    DispatchQueue.main.async {
                        self.categoryTableView.reloadData()
                        NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            })
        }
        
        completeButton.cornerRadius = 10
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        completeButton.tintColor = .white
        
        malert.addAction(cancelButton)
        malert.addAction(completeButton)
    
        DispatchQueue.main.async {
            self.present(malert, animated: true, completion: nil)
        }
    }
    
    func editCategory(oldCategory: String) {
        let view = CategoryAlertView.instantiateFromNib()
        view.categoryTextField.text = oldCategory
        
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
            self.updateVideoWithCategoryEdit(oldCategory: oldCategory, newCategory: "")
            self.updateCategoryName(oldCategory: oldCategory, newCategory: "")
        }
        
        deleteButton.cornerRadius = 10
        deleteButton.backgroundColor = .systemPink
        deleteButton.tintColor = .white
    
        let completeButton = MalertAction(title: "수정") {
            guard let newCategory = view.categoryTextField.text else {
                NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error)
                return
            }
            
            if oldCategory == newCategory {
                return
            }
            
            self.updateVideoWithCategoryEdit(oldCategory: oldCategory, newCategory: newCategory)
            self.updateCategoryName(oldCategory: oldCategory, newCategory: newCategory)
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
    
    func updateVideoWithCategoryEdit(oldCategory: String, newCategory: String) {
        let params: Parameters = ["oldCategory" : oldCategory, "newCategory" : newCategory, "userID" : self.userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable/update_all_videos_with_category.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                self.updateCategoryName(oldCategory: oldCategory, newCategory: newCategory)
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func updateCategoryName(oldCategory: String, newCategory: String) {
        guard let index = self.categories.firstIndex(of: oldCategory) else { return }
        
        if newCategory.isEmpty {
            self.categories.remove(at: index)
        } else {
            self.categories[index] = newCategory
        }
        
        let listString = self.categories.joined(separator: ",")
        let params: Parameters = ["categories" : listString, "userID" : self.userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable/update_categories.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setCategories(categories: self.categories)
                self.videoCategories = self.categories
                self.videoCategories.removeAll { category in
                    category == "전체영상" || category == "설정"
                }
                
                DispatchQueue.main.async {
                    self.categoryTableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
