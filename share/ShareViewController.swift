//
//  ShareViewController.swift
//  share
//
//  Created by SOO HYUN CHO on 12/26/23.
//

import UIKit
import Social
import CoreServices

class ShareViewController: UIViewController {
    
    private let appUrlString = "MyYou://home?url="
    private let typeText = String(kUTTypeText)
    private let typeUrl = String(kUTTypeURL)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        
        if itemProvider.hasItemConformingToTypeIdentifier(typeText) {
            self.handleIncomingText(itemProvider: itemProvider)
        } else if itemProvider.hasItemConformingToTypeIdentifier(typeUrl) {
            self.handleIncomingUrl(itemProvider: itemProvider)
        } else {
            print("error: no url or text found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    private func handleIncomingText(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: self.typeText, options: nil) { item, error in
            guard error == nil,
            let text = item as? String,
                  let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return }
            
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            if let firstMatch = matches.first,
               let range = Range(firstMatch.range, in: text) {
                let saveData = UserDefaults.init(suiteName: "group.com.chopas.jungbonet.myyouapp.share")
                let url = String(describing: text[range])
                
                DispatchQueue.main.async {
                    saveData?.set(url, forKey: "urlData")
                    saveData?.synchronize()
                    self.openMainApp()
                }
            }
        }
    }
    
    private func handleIncomingUrl(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: typeUrl, options: nil) { (item, error) in
            if let error = error {
                print("URL-Error: \(error.localizedDescription)")
            }
            
            if let url = item as? NSURL, let urlString = url.absoluteString {
                DispatchQueue.main.async {
                    let saveData = UserDefaults.init(suiteName: "group.com.chopas.jungbonet.myyouapp.share")
                    saveData?.set(urlString, forKey: "urlData")
                    saveData?.synchronize()
                    self.openMainApp()
                }
            }
        }
    }
    
    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: self.appUrlString) else { return }
            
            _ = self.openURL( url)
        })
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            
            responder = responder?.next
        }
        
        return false
    }
}
