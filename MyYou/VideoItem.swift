//
//  VideoItem.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation

public struct VideoItem: Decodable {
    let ownerID: String
    let videoID: String
    let title: String
    let categoryName: String
    let categoryID: String
}


public struct VideoItemList: Decodable {
    let product: [VideoItem]
}
