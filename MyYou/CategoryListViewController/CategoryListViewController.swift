//
//  CategoryListViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import UIKit
import Malert
import JDStatusBarNotification

class CategoryListViewController: UIViewController {
    @IBOutlet weak var categoryTableView: UITableView!
    
    let database = Manager.shared.getDB()
    let userID = Manager.shared.getUserID()
    var categories: [String] = []
    var showAll: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryTableView.register(UINib(nibName: "CategoryListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CategoryListTableViewCell")
        
        self.loadCategories()
        self.addRightButton()
    }
    
    func loadCategories() {
        let documentReference = self.database.collection(userID).document("categories")
        documentReference.getDocument { documentSnapshot, error in
            guard error == nil else { return }
            
            if var categories = documentSnapshot?.get("order") as? [String] {
                self.showAll = categories.first == "전체영상"
                
                categories.removeAll { category in
                    category == "설정" || category == "전체영상"
                }
                
                self.categories = categories
                
                self.categoryTableView.dataSource = self
                self.categoryTableView.delegate = self
                self.categoryTableView.dragInteractionEnabled = true
                self.categoryTableView.dragDelegate = self
            }
        }
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
            
            let documentReference = self.database.collection(self.userID).document("categories")
            documentReference.getDocument { documentSnapshot, error in
                guard error == nil,
                      var updatedCategories = documentSnapshot?.get("order") as? [String] else { return }
                
                if updatedCategories.first == "전체영상" {
                    updatedCategories.insert(newCategory, at: 1)
                } else {
                    updatedCategories.insert(newCategory, at: 0)
                }
                
                documentReference.updateData(["order": updatedCategories]) { error in
                    guard error == nil else {
                        NotificationPresenter.shared.present(error!.localizedDescription, includedStyle: .error)
                        return
                    }
                    
                    updatedCategories.removeAll { category in
                        category == "전체영상" || category == "설정"
                    }
                    
                    self.categories = updatedCategories
                    self.categoryTableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
                }
            }
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
        self.database.collection(userID).whereField("category", isEqualTo: oldCategory).getDocuments { querySnapshot, error in
            guard error == nil,
                  let documentSnapshots = querySnapshot?.documents else { return }
            
            for documentSnapshot in documentSnapshots {
                let documentReference = self.database.collection(self.userID).document(documentSnapshot.documentID)
                documentReference.updateData(["category": newCategory])
            }
        }
    }
    
    func updateCategoryName(oldCategory: String, newCategory: String) {
        let documentReference = self.database.collection(userID).document("categories")
        documentReference.getDocument { documentSnapshot, error in
            guard error == nil,
                  var updatedCategories = documentSnapshot?.get("order") as? [String] else { return }
            
            guard let index = updatedCategories.firstIndex(of: oldCategory) else { return }
            
            if newCategory.isEmpty {
                updatedCategories.remove(at: index)
            } else {
                updatedCategories.insert(newCategory, at: index)
                updatedCategories.remove(at: index + 1)
            }
            
            documentReference.updateData(["order": updatedCategories]) { error in
                guard error == nil else {
                    NotificationPresenter.shared.present(error!.localizedDescription, includedStyle: .error)
                    return
                }
                
                updatedCategories.removeAll { category in
                    category == "전체영상" || category == "설정"
                }
                
                self.categories = updatedCategories
                self.categoryTableView.reloadData()
                NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
            }
        }
    }
}
