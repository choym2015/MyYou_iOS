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
    let videoOrder: String
}

extension User {
    func updateManager() {
        Manager.shared.setUserID(userID: self.userID)
        Manager.shared.setLastCategory(lastCategory: self.lastCategory)
        Manager.shared.setNewMessage(newMessage: self.newMessage == "true" ? true : false)
        Manager.shared.setShouldPlayNext(shouldPlayNext: self.playNext == "true" ? true : false)
        Manager.shared.setPlaybackSpeed(playbackSpeed: self.playbackSpeed)
        Manager.shared.setSubscription(subscription: self.subscription)
        Manager.shared.setPushEnabled(pushEnabled: self.pushEnabled == "true" ? true :  false)
        Manager.shared.setRepeatSelection(repeatSelection: self.repeatSelection.components(separatedBy: ","))
        Manager.shared.setSelectedRepeatSelection(selectedRepeatSelection: self.selectedRepeatSelection)
        Manager.shared.setShouldShowThumbnail(shouldShowThumbnail: self.thumbnail == "true" ? true : false)
        Manager.shared.setVideoOrderList(videoOrderList: self.videoOrder.components(separatedBy: ","))
        Manager.shared.setCategories(categories: self.categories.components(separatedBy: ","))
        Manager.shared.setUserPhoneNumber(userPhoneNumber: self.userPhoneNumber)
    }
}
