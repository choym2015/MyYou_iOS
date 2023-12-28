//
//  UIView+roundCorners.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 12/28/23.
//

import Foundation
import UIKit

extension UIView {
   
   public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      self.layer.mask = mask
   }
}
