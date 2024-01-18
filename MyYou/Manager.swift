//
//  Manager.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation
import FirebaseFirestore
public class Manager {
    public static let shared = Manager()
    
    private var categories: [String]!
    private var db: Firestore!
    private var userID: String!
    private var videoOrderList: [String]!
    private var shouldShowThumbnail: Bool!
    private var shouldPlayNext: Bool!
    private var repeatSelection: [String]!
    private var selectedRepeatSelection: String!
    private var userPhoneNumber: String!
    private var pushEnabled: Bool!
    private var iosFcmKey: String!
    private var lastCategory: String!
    private var newMessage: Bool!
    private var playbackSpeed: String!
    private var subscription: String!
    
    public func setCategories(categories: [String]) {
        self.categories = categories
    }
    
    public func getCategories() -> [String] {
        return self.categories
    }
    
    public func setDB(db: Firestore) {
        self.db = db
    }
    
    public func getDB() -> Firestore {
        return self.db
    }
    
    public func setUserID(userID: String) {
        self.userID = userID
    }
    
    public func getUserID() -> String {
        return userID
    }
    
    public func setVideoOrderList(videoOrderList: [String]) {
        self.videoOrderList = videoOrderList
    }
    
    public func getVideoOrderList() -> [String] {
        return self.videoOrderList
    }
    
    public func setShouldShowThumbnail(shouldShowThumbnail: Bool) {
        self.shouldShowThumbnail = shouldShowThumbnail
    }
    
    public func isShowThumbnail() -> Bool {
        return self.shouldShowThumbnail
    }
    
    public func setShouldPlayNext(shouldPlayNext: Bool) {
        self.shouldPlayNext = shouldPlayNext
    }
    
    public func isPlayNext() -> Bool {
        return self.shouldPlayNext
    }
    
    public func setRepeatSelection(repeatSelection: [String]) {
        self.repeatSelection = repeatSelection
    }
    
    public func getRepeatSelection() -> [String] {
        return self.repeatSelection
    }
    
    public func setSelectedRepeatSelection(selectedRepeatSelection: String) {
        self.selectedRepeatSelection = selectedRepeatSelection
    }
    
    public func getSelectedRepeatSelection() -> String {
        return selectedRepeatSelection
    }
    
    public func setUserPhoneNumber(userPhoneNumber: String) {
        self.userPhoneNumber = userPhoneNumber
    }
    
    public func getUserPhoneNumber() -> String {
        return userPhoneNumber
    }
    
    public func setPushEnabled(pushEnabled: Bool) {
        self.pushEnabled = pushEnabled
    }
    
    public func isPushEnabled() -> Bool {
        return self.pushEnabled
    }
    
    public func setIosFcmKey(iosFcmKey: String) {
        self.iosFcmKey = iosFcmKey
    }
    
    public func getIosFcmKey() -> String {
        return iosFcmKey
    }
    
    public func getLastCategory() -> String {
        return lastCategory
    }
    
    public func setLastCategory(lastCategory: String) {
        self.lastCategory = lastCategory
    }
    
    public func isNewMessage() -> Bool {
        return self.newMessage
    }
    
    public func setNewMessage(newMessage: Bool) {
        self.newMessage = newMessage
    }
    
    public func getPlaybackSpeed() -> String {
        return playbackSpeed
    }
    
    public func setPlaybackSpeed(playbackSpeed: String) {
        self.playbackSpeed = playbackSpeed
    }
    
    public func getSubscription() -> String {
        return subscription
    }
    
    public func setSubscription(subscription: String) {
        self.subscription = subscription
    }
}

