//
//  Category.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/16/24.
//

import Foundation

public struct Category: Decodable {
    let categoryID: String
    let ownerID: String
    let audienceID: String
    let categoryName: String
}
