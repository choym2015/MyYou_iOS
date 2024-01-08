//
//  RepeatViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/5/24.
//

import UIKit
import JDStatusBarNotification

class RepeatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addRepeatButton: UIButton!
    @IBOutlet weak var repeatTableView: ContentSizedTableView!
    @IBOutlet weak var repeatTextField: UITextField!
    
    var repeatSelections = Manager.shared.getRepeatSelection()
    var selectedRepeatSelection = Manager.shared.getSelectedRepeatSelection()
    let database = Manager.shared.getDB()
    let userID = Manager.shared.getUserID()
    
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
    }
    
    func setupUI() {
        cancelButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#FFFFFF")
        cancelButton.tintColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        cancelButton.layer.borderColor = UIColor().hexStringToUIColor(hex: "#4781ed").cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 20
        
        completeButton.layer.cornerRadius = 20
        completeButton.backgroundColor = UIColor().hexStringToUIColor(hex: "#4781ed")
        completeButton.tintColor = .white
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addSelectionNumber()
        return true
    }

    @IBAction func addRepeatButtonPressed(_ sender: UIButton) {
        self.addSelectionNumber()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        let documentReference = self.database.collection(userID).document("configurations")
        documentReference.updateData(["selectedRepeatSelection": self.selectedRepeatSelection]) { error in
            guard error == nil else {
                return
            }
            
            Manager.shared.setSelectedRepeatSelection(selectedRepeatSelection: self.selectedRepeatSelection)
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
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
        
        let documentReference = self.database.collection(userID).document("configurations")
        documentReference.updateData(["repeatSelection": sortedRepeatSelections])
        documentReference.updateData(["repeatSelection": sortedRepeatSelections]) { error in
            guard error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                Manager.shared.setRepeatSelection(repeatSelection: sortedRepeatSelections)
                self.repeatSelections = sortedRepeatSelections
                self.repeatTableView.reloadData()
                self.repeatTextField.text = ""
                self.repeatTextField.resignFirstResponder()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.repeatSelections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatTableViewCell", for: indexPath) as? RepeatTableViewCell else { return UITableViewCell() }
        
        let repeatNumber = self.repeatSelections[indexPath.row]
        cell.repeatLabel.text = repeatNumber
        
//        if repeatNumber == self.selectedRepeatSelection {
//            cell.isSelected = true
//            cell.accessoryType = .checkmark
//            
//        } else {
//            cell.isSelected = false
//            cell.accessoryType = .none
//        }
                
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
}
