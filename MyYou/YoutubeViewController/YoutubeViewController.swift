//
//  YoutubeViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/4/24.
//

import UIKit
import youtube_ios_player_helper
import FirebaseFirestore

class YoutubeViewController: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    var index: Int!
    var videoList: [VideoItem]!
    var time: String!
    let database = Manager.shared.getDB()
    let userID = Manager.shared.getUserID()
    var currentVideo: VideoItem!
    var repeatIndex: Int!
    let selectedRepeat = Manager.shared.getSelectedRepeatSelection()

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .landscape
        
        self.youtubePlayerView.delegate = self
        self.currentVideo = self.videoList[index]
        
        if selectedRepeat != "무한" {
            self.repeatIndex = (selectedRepeat as NSString).integerValue
        }
        
        if !self.time.isEmpty {
            let timeFloat = (self.time as NSString).floatValue
            self.youtubePlayerView.load(withVideoId: currentVideo.videoID, playerVars: ["start": timeFloat])
        } else {
            self.youtubePlayerView.load(withVideoId: currentVideo.videoID)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .portrait
        
        self.youtubePlayerView.currentTime { time, error in
            if error != nil {
                return
            } else {
                self.youtubePlayerView.duration { duration, error in
                    let documentReference = self.database.collection(self.userID).document("video_" + self.currentVideo.videoID)
                    if String(format: "%.0f", duration) == String(format: "%.0f", time) {
                        documentReference.updateData(["time": ""])
                    }
                    else {
                        documentReference.updateData(["time": String(format: "%.0f", time)])
                    }
                }
            }
        }
    }
    
    func receiveItem(index: Int, videoList: [VideoItem], time: String) -> Self {
        self.index = index
        self.videoList = videoList
        self.time = time
        
        return self
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        guard state == YTPlayerState.ended else { return }
        
        if self.selectedRepeat == "무한" {
            self.repeatVideo()
        } else if self.repeatIndex > 1 {
            self.repeatIndex -= 1
            self.repeatVideo()
        } else {
            self.repeatIndex = (self.selectedRepeat as NSString).integerValue
            self.playNextVideo()
        }
    }
    
    func repeatVideo() {
        self.youtubePlayerView.load(withVideoId: currentVideo.videoID)
    }
    
    func playNextVideo() {
        self.index += 1
        if self.index == self.videoList.count {
            self.dismiss(animated: true)
        } else {
            self.currentVideo = self.videoList[self.index]
            self.youtubePlayerView.load(withVideoId: currentVideo.videoID)
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
