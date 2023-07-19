//
//  ContentView.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/7.
//

import SwiftUI
import SpriteKit
import CoreImage

class GameScene: SKScene {
    let role = GameRole()
    
    override func sceneDidLoad() {
        self.size = resolution
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        
        self.addChild(dataSource.bg)
        self.addChild(dataSource.moveBtnSet)
        self.addChild(dataSource.actionBtnSet)
        
        self.addChild(role)
        
        
    }
    
    override func didMove(to view: SKView) {
        self.view?.isMultipleTouchEnabled = true

    }
    
    override func update(_ currentTime: TimeInterval) {
        role.handleUpdate()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let n = touches.count
        print("began touche counts \(n)")
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        guard let node = nodes.first else { return }
        
        if let name = node.name {
            if name.hasPrefix("move") {
                role.facingDirection = Direction(rawValue: Int(name.suffix(1))!)!
                role.handleBtnMove()
                
            } else {
                role.handleOtherTouch(name: name)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        role.endTouching()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let n = touches.count
        print("moving touche counts \(n)")
    }
    

}

