//
//  AppColor.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/10/21.
//

import Foundation
import UIKit

public struct AppColor {
    
    public static let marvelRed: UIColor = colorNamed("MarvelRed")
    public static let marvelBlack: UIColor = colorNamed("MarvelBlack")
    
    static func colorNamed(_ name: String?) -> UIColor {
        guard let n = name else { return UIColor() }
        return UIColor(named: n) ?? UIColor()
    }
}
