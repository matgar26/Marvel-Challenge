//
//  CharacterDetailViewController.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/12/21.
//

import UIKit
import SDWebImage
import SafariServices

class CharacterDetailViewController: UIViewController {
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var mainStack: UIStackView!
    
    var character: CharacterDTO?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateData()
        
        profileButton.layer.cornerRadius = 3
        imageView.layer.cornerRadius = 3
    }
    
    private func populateData() {
        guard let character = character else { return }
        
        imageView.contentMode = traitCollection.horizontalSizeClass == .regular ? .scaleAspectFill : .scaleAspectFit
        
        if let urlString = character.imageURL, let url = URL(string: urlString) {
//            imageView.sd_setImage(with: url)
            SDWebImageDownloader.shared.downloadImage(with: url) { image, _, _, _ in
                self.imageView.image = image?.sd_roundedCornerImage(withRadius: 6, corners: .allCorners, borderWidth: 2, borderColor: AppColor.marvelSecondary)
            }
        }

        nameLabel.text = character.name
        descriptionLabel.text = character.description
        descriptionLabel.isHidden = character.description == nil
        profileButton.isHidden = character.profileURL == nil
        
        mainStack.isHidden = false
    }

    @IBAction func didTapReadProfile(_ sender: Any) {
        if let urlString = character?.profileURL, let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
}
