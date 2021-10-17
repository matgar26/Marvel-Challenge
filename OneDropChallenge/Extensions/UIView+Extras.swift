//
//  UIView+Extras.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/16/21.
//

import Foundation
import UIKit

extension UIView {
    // MARK: - NSLayoutConstraint Convenience Methods
    
    func addAutoLayoutSubview(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func fillSuperview() {
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
    }
}
