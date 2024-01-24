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
    var closure: ((Category) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCategoryButton.layer.cornerRadius = 10
        self.categoryTableView.register(UINib(nibName: "RepeatTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RepeatTableViewCell")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.loadCategories()
        self.setupUI()
    }
    
    func receiveItem(selectedCategory: Category?, closure: @escaping (Category) -> Void) {
        self.selectedCategory = selectedCategory
        self.closure = closure
    }
    
    func loadCategories() {
//        self.categories.removeAll(where: { category in
//            category.categoryName == "사용법" || category.categoryName == "설정"
//        })
        
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
        addCategoryButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#6200EE")
        addCategoryButton.tintColor = .white
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func addCategory() {
        guard let category = self.categoryTextField.text, !category.isEmpty else {
            NotificationPresenter.shared.present("카테고리 제목을 입력해주세요", includedStyle: .error)
            return
        }
        
        if Helper.getCategory(categoryName: category) != nil {
            NotificationPresenter.shared.present("같은 이름의 카테고리가 있습니다", includedStyle: .error)
            return
        }
        
        let newCategory = Category(categoryID: UUID().uuidString, ownerID: Manager2.shared.getUserID(), audienceID: "", categoryName: category)
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
                    self.categoryTextField.text = ""
                    self.categoryTextField.resignFirstResponder()
                    self.categories.insert(newCategory, at: 0)
                    self.categoryTableView.reloadData()
                }
               
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        self.dismiss(animated: true) {
            self.closure(selectedCategory)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatTableViewCell", for: indexPath) as? RepeatTableViewCell else { return UITableViewCell() }
        
        cell.repeatLabel.text = self.categories[indexPath.row].categoryName
        
        return cell
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        self.addCategory()
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
