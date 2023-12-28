//
//  VideoListViewController.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import UIKit

class VideoListViewController: UIViewController {
    var category: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public func receiveCategory(category: String) -> UIViewController {
        self.category = category
        return self
    }


    func loadDb() {
        //load all the video documents
        // if category is not 전체영상, filter the videos (take a look at documentation)
        //call setCollectionView once we load all the videos
    }
    
    func setCollectionView() {
        
    }
}
