//
//  GameViewController.swift
//  MemoryGame
//
//  Created by Alexandr Filovets on 30.04.24.
//
import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        
        let skView = SKView(frame: view.bounds)
        skView.presentScene(scene)
        
        view.addSubview(skView)
    }
}
