//
//  LoadingCell.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/11/21.
//

import Foundation
import UIKit

final class LoadingCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    override var reuseIdentifier: String? {
        return "LoadingCollectionViewCell"
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicatorView.color = AppColor.tint
        
        contentView.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public

    func startAnimating() {
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
}
