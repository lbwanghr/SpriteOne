//
//  ContentView.swift
//  SpriteOne
//
//  Created by Haoran Wang on 2023/6/16.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    let scene = GameOne()
    
    var body: some View {
        
        #if os(macOS)
        SpriteView(scene: GameOne(), debugOptions: [.showsFPS, .showsNodeCount])
                .frame(minWidth: 512, maxWidth: 1024, minHeight: 384, maxHeight: 768)
        #elseif os(iOS)
        SpriteView(scene: GameOne(), debugOptions: [.showsFPS, .showsNodeCount])
                .ignoresSafeArea()
        #elseif os(watchOS)
        
        VStack {
            SpriteView(scene: scene)
                    .ignoresSafeArea()
            Button("Move") {
                scene.doWatchThing()
            }
        }

        #endif
        
        
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    ContentView()
}



class GameOne: SKScene {
    
    var touchingPlayer = false
    var lastLocation = CGPoint()
    
    var timer: Timer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    let music = SKAudioNode(fileNamed: "cyborg-ninja")
    let background = SKSpriteNode(imageNamed: "space")
    let player = SKSpriteNode(imageNamed: "player-rocket")
    let gameOver = SKSpriteNode(imageNamed: "gameOver-1")
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let spaceDust = SKEmitterNode(fileNamed: "SpaceDust")!
    let explosionSound = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
    
    
    override func sceneDidLoad() {
        // Initialize scene configuration
        self.size = CGSize(width: 960, height: 540)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        self.physicsWorld.contactDelegate = self
        
        background.zPosition = -1
        
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: 300, y: 200)
        score = 0
        
        spaceDust.zPosition = 0
        spaceDust.position = CGPoint(x: 480, y: 0)
        spaceDust.advanceSimulationTime(10)
        
        player.zPosition = 0
        player.position = CGPoint(x: -400, y: 0)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.affectedByGravity = false
        
        addChild(player)
        addChild(background)
        background.addChild(music)
        background.addChild(scoreLabel)
        background.addChild(spaceDust)
        
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { timer in
            self.createEnemy()
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if touchingPlayer == false && player.parent != nil {
            score += 1
        }
        
        if player.position.x > 440 {
            player.position.x = 440
        } else if player.position.x < -440 {
            player.position.x = -440
        }
        
        if player.position.y > 230 {
            player.position.y = 230
        } else if player.position.y < -230 {
            player.position.y = -230
        }
        
        for node in children {
            if node.position.x < -480 {
                node.removeFromParent()
            }
        }
    }
    
    func createEnemy() {
        let sprite = SKSpriteNode(imageNamed: "asteroid")
        sprite.position = CGPoint(x: 600, y: Int.random(in: -270..<270))
        sprite.name = "enemy"
        sprite.zPosition = 1
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -200, dy: 0)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
        addChild(sprite)
    }
    

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        if tappedNodes.contains(player) {
            touchingPlayer = true
            lastLocation = location
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position = player.position + location - lastLocation
        lastLocation = location
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
    }
    #endif
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        
        let location = event.location(in: self)
        let nodes = nodes(at: location)
        if nodes.contains(player) {
            touchingPlayer = true
            lastLocation = location
        }
    }
    override func mouseDragged(with event: NSEvent) {
        guard touchingPlayer else { return }
        let location = event.location(in: self)
        player.position = player.position + location - lastLocation
        lastLocation = location
    }
    
    override func mouseUp(with event: NSEvent) {
        touchingPlayer = false
    }
    #endif
    
    #if os(watchOS)
    // no guesture
    func doWatchThing() {
        player.physicsBody?.velocity = CGVector(dx: 20, dy: 0)
    }
    #endif
        

}

extension GameOne: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA == player {
            playerHit(nodeB)
        }
    }
    
    func playerHit(_ node: SKNode) {
        
        run(explosionSound)
        music.removeFromParent()
        
        gameOver.zPosition = 3
        background.addChild(gameOver)
        
        if let exPlayer = SKEmitterNode(fileNamed: "Explosion") {
            exPlayer.position = player.position
            exPlayer.zPosition = 3
            background.addChild(exPlayer)
        }
        
        if let exEnemy = SKEmitterNode(fileNamed: "Explosion") {
            exEnemy.position = node.position
            exEnemy.zPosition = 3
            background.addChild(exEnemy)
        }
        
        player.removeFromParent()
        node.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //self.view?.presentScene(GameOne())
        }
    }
}


extension CGPoint {
    static func + (p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
    }
    static func - (p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
    }
}
