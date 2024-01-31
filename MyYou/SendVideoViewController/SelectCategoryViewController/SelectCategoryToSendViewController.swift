//
//  SelectCategoryToSendViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/30/24.
//

import UIKit

class SelectCategoryToSendViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let categories = Manager2.shared.user.categories
    var selectedCategory: Category?
    var phoneNumbers: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "카테고리 선택"
        
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RepeatTableViewCell")
    }

    func receiveItem(phoneNumbers: [String]) {
        self.phoneNumbers = phoneNumbers
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        guard let selectedCategory = self.selectedCategory else { return }
        
        DispatchQueue.main.async {
            let selectVideoToSendVC = SelectVideoToSendViewController(nibName: "SelectVideoToSendViewController", bundle: Bundle.main)
            selectVideoToSendVC.receiveItem(phoneNumbers: self.phoneNumbers, category: selectedCategory)
            
            self.navigationController?.pushViewController(selectVideoToSendVC, animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
