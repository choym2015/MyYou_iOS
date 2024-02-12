//
//  SelectCategoryViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import UIKit
import JDStatusBarNotification
import Alamofire

class SelectCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryTableView: ContentSizedTableView!
    @IBOutlet weak var cancelImage: UIImageView!
    
    var categories = Manager2.shared.getCategories()
    var selectedCategory: Category?
    var closure: ((Category?, Bool) -> Void)!
    var updateRequired: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCategoryButton.layer.cornerRadius = 10
        self.categoryTableView.register(UINib(nibName: "RepeatTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RepeatTableViewCell")
        
        self.loadCategories()
        self.setupUI()
    }
    
    func receiveItem(selectedCategory: Category?, closure: @escaping (Category?, Bool) -> Void) {
        self.selectedCategory = selectedCategory
        self.closure = closure
    }
    
    func loadCategories() {
        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        self.categoryTableView.delegate = self
        
        guard self.selectedCategory != nil,
              let index = self.categories.firstIndex(where: { category in
                  category.categoryID == self.selectedCategory?.categoryID
              }) else { return }
        self.categoryTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }
    
    func setupUI() {
        cancelImage.isUserInteractionEnabled = true
        cancelImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        categoryTextField.delegate = self
        addCategoryButton.layer.cornerRadius = 10
        addCategoryButton.backgroundColor = .cancel
        addCategoryButton.tintColor = .white
        addCategoryButton.isEnabled = false
        addCategoryButton.isUserInteractionEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text,
           !text.isEmpty {
            addCategoryButton.backgroundColor = .colorPrimary
            addCategoryButton.isEnabled = true
            addCategoryButton.isUserInteractionEnabled = true
        } else {
            addCategoryButton.backgroundColor = .cancel
            addCategoryButton.isEnabled = false
            addCategoryButton.isUserInteractionEnabled = false
        }
    }
    
    func addCategory() {
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
                    self.categoryTextField.text = ""
                    self.categories.insert(newCategory, at: 1)
                    self.categoryTableView.reloadData()
                    self.updateRequired = true
                }
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error, duration: 2.0)
                self.handleDismiss()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        
        self.dismiss(animated: true) {
            self.closure(selectedCategory, self.updateRequired)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatTableViewCell", for: indexPath) as? RepeatTableViewCell else { return UITableViewCell() }
        
        let category = self.categories[indexPath.row]
        
        cell.repeatLabel.text = category.categoryName
        
        if category.categoryName == "사용법" || category.categoryName == "설정" || !category.isOwner() {
            cell.selectionStyle = .none
            cell.repeatLabel.textColor = .lightGray
            cell.isUserInteractionEnabled = false
        } else {
            cell.selectionStyle = .default
            cell.repeatLabel.textColor = .black
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        self.addCategory()
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true) {
            self.closure(nil, self.updateRequired)
        }
    }
}
