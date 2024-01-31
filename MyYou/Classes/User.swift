//
//  User.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/16/24.
//

import Foundation

public struct User: Codable {
    let userID: String
    let lastCategory: String
    let newMessage: String
    let playNext: String
    let playbackSpeed: String
    let subscription: String
    let pushEnabled: String
    let repeatSelection: String
    let selectedRepeatSelection: String
    let thumbnail: String
    let userPhoneNumber: String
    let categories: String
    let duplicateVideoIDs: [String]
}
