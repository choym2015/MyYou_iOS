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
    private var premium: Bool!
    private var pushEnabled: Bool!
    private var iosFcmKey: String!
    
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
    
    public func setPremium(premium: Bool) {
        self.premium = premium
    }
    
    public func isPremium() -> Bool {
        return self.premium
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
    
    public func setManager(documentSnapShot: DocumentSnapshot, closure: () -> ()) {
        guard let playNext = documentSnapShot.get("playNext") as? Bool,
              let premium = documentSnapShot.get("premium") as? Bool,
              let pushEnabled = documentSnapShot.get("pushEnabled") as? Bool,
              let repeatSelection = documentSnapShot.get("repeatSelection") as? [String],
              let selectedRepeatSelection = documentSnapShot.get("selectedRepeatSelection") as? String,
              let thumbnail = documentSnapShot.get("thumbnail") as? Bool,
              let userPhoneNumber = documentSnapShot.get("userPhoneNumber") as? String else { return }
        
        self.shouldPlayNext = playNext
        self.premium = premium
        self.pushEnabled = pushEnabled
        self.repeatSelection = repeatSelection
        self.selectedRepeatSelection = selectedRepeatSelection
        self.shouldShowThumbnail = thumbnail
        self.userPhoneNumber = userPhoneNumber
        
        closure()
    }
}

