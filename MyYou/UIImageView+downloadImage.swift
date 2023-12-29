//
//  UIImageView+downloadImage.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    let resizedImage = image.resizeImage(targetSize: CGSize(width: self.frame.width, height: self.frame.height))
                    self.image = resizedImage
                }
            }
        }.resume()
    }
}
