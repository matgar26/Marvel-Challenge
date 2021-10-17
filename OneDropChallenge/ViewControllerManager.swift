//
//  ViewControllerManager.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/11/21.
//

import Foundation
import UIKit
import Combine

class ViewControllerManager {
    
    // MARK: - Handle Storybaord ViewControllers
    static let shared = ViewControllerManager()

    enum Storyboards: String {
        case Main
    }
    
    enum ViewControllers {
        enum Main: String {
            case charecterList = "CharecterListViewController"
            case charecterDetail = "CharacterDetailViewController"
        }
    }
    
    typealias StoryboardIdentifier = Storyboards
    
    private func loadScene<ViewControllerIdentifier: RawRepresentable>(storyboard: StoryboardIdentifier, viewController: ViewControllerIdentifier) -> UIViewController where ViewControllerIdentifier.RawValue == String {
        return UIStoryboard.init(name: storyboard.rawValue, bundle: nil).instantiateViewController(withIdentifier: viewController.rawValue)
    }
    
}

extension ViewControllerManager {
    
    func charecterListViewController() -> CharecterListViewController {
        let vc = loadScene(storyboard: Storyboards.Main, viewController: ViewControllers.Main.charecterList) as! CharecterListViewController
        return vc
    }
    
    func characterDetailViewController(character: CharacterDTO) -> CharacterDetailViewController {
        let vc = loadScene(storyboard: Storyboards.Main, viewController: ViewControllers.Main.charecterDetail) as! CharacterDetailViewController
        vc.character = character
        return vc
    }
    
    func charecterSearchResultsController(searchSelection: PassthroughSubject<CharacterDTO, Never>) -> CharacterSearchResultsViewController {
        let vc = CharacterSearchResultsViewController()
        vc.searchSelection = searchSelection
        return vc
    }
}
