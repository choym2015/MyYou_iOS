//
//  VideoCollectionViewCell.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var videoTitle: PaddingLabel!
    @IBOutlet weak var videoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
            
        layoutAttributes.frame = frame

        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect:bounds, cornerRadius:contentView.layer.cornerRadius).cgPath
    }
}
