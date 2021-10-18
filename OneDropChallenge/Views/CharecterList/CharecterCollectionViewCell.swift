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
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet var separatorViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3
        self.layer.borderColor = AppColor.marvelSecondary.cgColor
        self.layer.borderWidth = 0.5
        imageView.isSkeletonable = true
    }
    
    func configure(with character: CharacterDTO) {
        hideSkeleton()
        nameLabel.text = character.name

        if let urlString = character.imageURL, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url)
        } else {
            imageView.sd_setImage(with: nil)
        }
    }
    
    func configure(with character: CharacterEntity) {
        hideSkeleton()
        nameLabel.text = character.name

        if let urlString = character.imageUrl, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url)
        } else {
            imageView.sd_setImage(with: nil)
        }
    }
    
    func configure() {
        self.layer.borderColor = AppColor.marvelSecondary.cgColor
        self.layer.borderWidth = 0.5
        nameLabel.text = nil
        imageView.image = nil
        showSkeleton()
    }
    
    private func showSkeleton() {
        // Add delay for skeleton to get the right frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.imageView.showAnimatedGradientSkeleton()
        }
    }
    
    private func hideSkeleton() {
        imageView.hideSkeleton()
    }
    
    /// Cell selection animation
    override var isSelected: Bool {
        didSet {
            self.separatorHeightConstraint.isActive = !isSelected
            self.separatorViewBottomConstraint.isActive = isSelected
            
            UIView.animate(withDuration: 0.15) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
}
