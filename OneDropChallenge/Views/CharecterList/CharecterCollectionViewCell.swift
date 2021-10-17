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
    
    private func showSkeleton() {
        imageView.showAnimatedGradientSkeleton()
    }
    
    private func hideSkeleton() {
        imageView.hideSkeleton()
    }
    
    func animate(completion: @escaping () -> Void) {
        // If we are on IPad, dont re-animate if you are tapping the same cell
        if !separatorHeightConstraint.isActive {
            return
        }
        
        self.separatorHeightConstraint.isActive = false
        self.separatorViewBottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.layoutIfNeeded()
        } completion: { [weak self] success in
            completion()
            self?.reset()
        }
    }
    
    func reset() {
        // Keep the selected cell styling if we are on iPad
        if traitCollection.horizontalSizeClass != .regular {
            
            // Add a delay to give parent view controller to push to detail view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.separatorHeightConstraint.isActive = true
                self?.separatorViewBottomConstraint.isActive = false
                self?.layoutIfNeeded()
            }
        }
    }
}
