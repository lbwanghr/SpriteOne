//
//  ContentView.swift
//  SpriteOne
//
//  Created by Haoran Wang on 2023/6/16.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 1024, height: 768)
        scene.scaleMode = .fill
        return scene
    }
    var body: some View {
        SpriteView(scene: scene, debugOptions: [.showsFPS, .showsNodeCount])
            .ignoresSafeArea()
        
        
    }
}

#Preview {
    ContentView()
}

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player-rocket")
    
    var touchingPlayer = false
    var lastLocation = CGPoint()
    
    var timer: Timer?
    
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    let music = SKAudioNode(fileNamed: "cyborg-ninja")
    
    func initialization(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "space")
        bg.zPosition = -1
        bg.position = CGPoint(x: 512, y: 384)
        addChild(bg)
        
        if let particles = SKEmitterNode(fileNamed: "SpaceDust") {
            particles.position = CGPoint(x: 1024, y: 384)
            particles.zPosition = 0
            particles.advanceSimulationTime(10)
            addChild(particles)
        }
        
        
        player.position = CGPoint(x: 0, y: 384)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.affectedByGravity = false
        addChild(player)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.35, repeats: true, block: { timer in
            self.createEnemy()
        })
        physicsWorld.contactDelegate = self
        
        
        scoreLabel.zPosition = 2
        scoreLabel.position = CGPoint(x: 100, y: 200)
        score = 0
        addChild(scoreLabel)
        
        addChild(music)
    }
    
    override func didMove(to view: SKView) {
        initialization(to: view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if touchingPlayer == false && player.parent != nil {
            score += 1
        }
        
        if player.position.x > 924 {
            player.position.x = 924
        } else if player.position.x < 100 {
            player.position.x = 100
        }
        
        if player.position.y > 668 {
            player.position.y = 668
        } else if player.position.y < 100 {
            player.position.y = 100
        }
        
        for node in children {
            if node.position.x < 0 {
                node.removeFromParent()
            }
        }
    }
    
    func createEnemy() {
        let sprite = SKSpriteNode(imageNamed: "asteroid")
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 0...768))
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
    


}

extension CGPoint {
    static func + (p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
    }
    static func - (p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }
    func playerHit(_ node: SKNode) {
        let sound = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
        run(sound)
        
        music.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver-1")
        gameOver.zPosition = 3
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
        
        if let particles = SKEmitterNode(fileNamed: "Explosion") {
            particles.position = player.position
            particles.zPosition = 3
            addChild(particles)
        }
        
        if let particles = SKEmitterNode(fileNamed: "Explosion") {
            particles.position = node.position
            particles.zPosition = 3
            addChild(particles)
        }
        
        player.removeFromParent()
        node.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.removeAllChildren()
            self.initialization(to: self.view!)
        }
    }
}


struct Previews_ContentView_LibraryContent: LibraryContentProvider {
    var views: [LibraryItem] {
        LibraryItem(/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/)
    }
}
