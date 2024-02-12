//
//  Configuration.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/15/24.
//

import Foundation

struct Configuration: Codable {
    let bomb: String
    let version: String
    let iosVersion: String
    let hardUpdateRequired: String
    let fcmKey: String
}
