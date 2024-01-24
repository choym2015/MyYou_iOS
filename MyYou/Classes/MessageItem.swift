//
//  MessageItem.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import Foundation

public struct MessageItem: Decodable {
    let timestamp: String
    let messageID: String
    let downloaded: Bool
    let category: Category
}

public struct MessageItemList: Decodable {
    let product: [MessageItem]
}
