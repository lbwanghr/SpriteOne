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
    var bg = SKNode()
    var moveBtnSet = SKNode()
    var actionBtnSet = SKNode()
    var touchedNodes = [UITouch: SKNode]() // Record every touch which binding to a node.
    
    override func sceneDidLoad() {
        size = resolution
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .aspectFit
        
        bg = generateBackground()
        addChild(bg)
        
        moveBtnSet = generateMoveButtons()
        addChild(moveBtnSet)
        
        actionBtnSet = generateActionButtons()
        addChild(actionBtnSet)
        
        role.configuration()
        addChild(role)
        
        
        
    }
    
    override func didMove(to view: SKView) {
        self.view?.isMultipleTouchEnabled = true

    }
    
    override func update(_ currentTime: TimeInterval) {
        role.update()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            guard let node = nodes.first else { continue }
            
            if let name = node.name {
                if name.hasPrefix("move") {
                    role.facingDirection = Direction(rawValue: Int(name.suffix(1))!)!
                    role.handleMoveBtnTouchBegan()
                    touchedNodes[touch] = node  // Record this node with UITouch key.
                    
                } else if let actionType = ActionType(rawValue: name){
                    
                    role.handleActionBtnTouchBegan(name: name)
                    touchedNodes[touch] = node
                } else {
                    
                }
            }
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let node = touchedNodes[touch] {
                if let name = node.name {
                    if name.hasPrefix("move") {
                        role.handleMoveBtnTouchEnd()
                        
                    }
                }

            }
            touchedNodes.removeValue(forKey: touch)
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    

    
    /// Generate background
    /// - Tiles are attached to a sknode called bg.
    /// - Note: sknode has no anchorPoint property, that means the anchorPoint is .zero.
    func generateBackground() -> SKNode {
        let bg = SKNode()
        let (rows, cols) = (Int(resolution.height) / 16, Int(resolution.width) / 16)
        let tileNames = ["Dirt", "Grass1", "Grass2"]
        let bgTree = "Tree"
        
        bg.position = CGPoint(x: resolution.width / -2, y: resolution.height / -2)
        
        // Generate tiles(designate tile's anchorPoint to .zero)
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let tile = SKSpriteNode(imageNamed: tileNames.randomElement()!)
                tile.anchorPoint = .zero
                tile.position = CGPoint(x: col * 16, y: row * 16)
                tile.zPosition = -1
                
                bg.addChild(tile)
            }
        }
        // Generate trees(tree's anchorPoint is default .center)
        for _ in 0 ..< numberOfTree {
            let tree = SKSpriteNode(imageNamed: bgTree)
            tree.position = CGPoint(x: Double.random(in: 0 ..< resolution.width), y: Double.random(in: 0 ..< resolution.height))
            
            let physicsBody = SKPhysicsBody(texture: tree.texture!, size: tree.size)
            tree.physicsBody = physicsBody
            physicsBody.mass = 1000
            physicsBody.allowsRotation = false
            physicsBody.affectedByGravity = false
            
            bg.addChild(tree)
        }
        return bg
    }
    
    /// Generate buttons' texture and arrange their position
    /// - Buttons are attached to two btnSet sknodes.
    func generateMoveButtons() -> SKNode {
        let root = SKNode()
        for direction in Direction.allCases {
            let btn = SKSpriteNode()
            let uiImg = UIImage(systemName: "arrowshape.down.fill")!
            btn.texture = SKTexture(image: uiImg)
            btn.zRotation = CGFloat.pi / 4 * -1 * CGFloat(direction.rawValue - 7)
            btn.zPosition = 1
            btn.alpha = btnAlpha
            btn.position = CGPoint(x: (CGFloat(direction.rawValue) - 3.5) * btnInterval, y: 0)
            btn.size = btnSize
            btn.name = "move\(direction.rawValue)"
            root.addChild(btn)
            root.position = moveBtnPosition
            
        }
        return root
    }
    
    func generateActionButtons() -> SKNode {
        let root = SKNode()
        var actionBtnXOffset = -1
        for actionType in ActionType.allCases {
            actionBtnXOffset += 1
            let btn = SKSpriteNode()
            btn.zPosition = 1
            let btnCount = ActionType.allCases.count
            btn.position.x = (CGFloat(actionBtnXOffset) - CGFloat(btnCount - 1) * 0.5) * btnInterval
            btn.alpha = btnAlpha
            
            let imgName = actionType.rawValue
            btn.texture = SKTexture(imageNamed: imgName)
            
            btn.size = btnSize
            btn.name = imgName
            root.addChild(btn)
            root.position = actionBtnPosition
        }
        return root
    }
    
}

