//
//  VideoAddLauncher.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/26/23.
//

import UIKit

class VideoAddLauncher: NSObject {

    let blackView = UIView()
    lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    func showSettings() {
        if let window = UIApplication.shared.keyWindow{
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            window.addSubview(popupView)
            
            let height: CGFloat = window.frame.height*3/4
            let y = window.frame.height - height
            popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                self.popupView.frame = CGRect(x: 0, y: y, width: self.popupView.frame.width, height: self.popupView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: self.popupView.frame.width, height: self.popupView .frame.height)
            }
        }
    }
    
}
