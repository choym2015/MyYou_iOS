//
//  RepeatViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/5/24.
//

import UIKit
import JDStatusBarNotification
import Alamofire

class RepeatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addRepeatButton: UIButton!
    @IBOutlet weak var repeatTableView: ContentSizedTableView!
    @IBOutlet weak var repeatTextField: UITextField!
    
    var repeatSelections = Manager2.shared.user.repeatSelections
    var selectedRepeatSelection = Manager2.shared.user.selectedRepeatSelection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.repeatTableView.register(UINib(nibName: "RepeatTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RepeatTableViewCell")
        self.repeatTableView.delegate = self
        self.repeatTableView.dataSource = self
        self.repeatTextField.delegate = self
    
        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        guard let index = self.repeatSelections.firstIndex(of: self.selectedRepeatSelection) else { return }
        self.repeatTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.repeatTextField.resignFirstResponder()
    }
    
    func setupUI() {
        cancelButton.backgroundColor = .cancel
        cancelButton.tintColor = .white
        cancelButton.layer.cornerRadius = 10
        
        completeButton.layer.cornerRadius = 10
        completeButton.backgroundColor = .colorPrimary
        completeButton.tintColor = .white
        
        addRepeatButton.backgroundColor = .cancel
        addRepeatButton.isUserInteractionEnabled = false
        addRepeatButton.isEnabled = false
        addRepeatButton.layer.cornerRadius = 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addSelectionNumber()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text,
           !text.isEmpty {
            addRepeatButton.backgroundColor = .colorPrimary
            addRepeatButton.isEnabled = true
            addRepeatButton.isUserInteractionEnabled = true
        } else {
            addRepeatButton.backgroundColor = .cancel
            addRepeatButton.isEnabled = false
            addRepeatButton.isUserInteractionEnabled = false
        }
    }

    @IBAction func addRepeatButtonPressed(_ sender: UIButton) {
        self.addSelectionNumber()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        self.updateSelectedRepeatSelection()
    }
    
    func addSelectionNumber() {
        guard let number = self.repeatTextField.text else {
            NotificationPresenter.shared.present("반복 재생 횟수를 입력해주세요", includedStyle: .error)
            return
        }
        
        var sortedRepeatSelections = self.repeatSelections
        sortedRepeatSelections.append(number)
        sortedRepeatSelections.sort { (lhs: String, rhs: String) -> Bool in
            if lhs == "무한" {
                return false
            } else if rhs == "무한" {
                return true
            } else {
                return Int(lhs)! < Int(rhs)!
            }
        }
        
        self.updateRepeatSelections(repeatSelections: sortedRepeatSelections)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.repeatSelections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatTableViewCell", for: indexPath) as? RepeatTableViewCell else { return UITableViewCell() }
        
        let repeatNumber = self.repeatSelections[indexPath.row]
        cell.repeatLabel.text = repeatNumber
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRepeatSelection = self.repeatSelections[indexPath.row]
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func updateSelectedRepeatSelection() {
        let params: Parameters = ["selectedRepeatSelection" : self.selectedRepeatSelection, "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_selected_repeat_selection.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager2.shared.user.selectedRepeatSelection = self.selectedRepeatSelection
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
    
    func updateRepeatSelections(repeatSelections: [String]) {
        let listString = repeatSelections.joined(separator: ",")
        let params: Parameters = ["repeatSelection" : listString, "userID" : Manager2.shared.getUserID()]
        
        AF.request("https://chopas.com/smartappbook/myyou/userTable3/update_repeat_selections.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager2.shared.user.repeatSelections = repeatSelections
                DispatchQueue.main.async {
                    self.repeatSelections = repeatSelections
                    self.repeatTableView.reloadData()
                    self.repeatTextField.text = ""
                    self.repeatTextField.resignFirstResponder()
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
