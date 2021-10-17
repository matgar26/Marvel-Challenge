//
//  CharecterCollectionViewCell.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/10/21.
//

import UIKit
import SDWebImage
import SkeletonView

class CharecterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.isSkeletonable = true
    }
    
    func configure(with charecter: CharacterDTO) {
        hideSkeleton()
        nameLabel.text = charecter.name
        
        if let urlString = charecter.imageURL, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url)
        } else {
            imageView.sd_setImage(with: nil)
        }
    }
    
    func configure() {
        nameLabel.text = nil
        imageView.image = nil
        showSkeleton()
    }
    
    func showSkeleton() {
        imageView.showAnimatedGradientSkeleton()
    }
    
    func hideSkeleton() {
        imageView.hideSkeleton()
    }
}
