//
//  Audience.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/29/24.
//

import Foundation

public struct Audience: Decodable {
    let userID: String
    let userPhoneNubmer: String
    let categoryID: String
}


public struct Audiences: Decodable {
    let product: [Audience]?
}
