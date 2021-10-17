//
//  SeachEmptyStateView.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/16/21.
//

import Foundation
import UIKit

class SearchEmptyStateView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = Bundle.main.loadNibNamed("SearchEmptyStateView", owner: self, options: nil)?.first as! UIView
        addAutoLayoutSubview(contentView)
        contentView.fillSuperview()
    }
}
