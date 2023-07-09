//
//  ContentView.swift
//  SpriteOne
//
//  Created by Haoran Wang on 2023/6/16.
//

import SwiftUI
import SpriteKit
import CoreMotion
#if !os(watchOS)
import WebKit
#endif

struct ContentView: View {
    
    let scene = GameOne()
    
    var body: some View {
        
        #if os(macOS)
        SpriteView(scene: GameOne(), debugOptions: [.showsFPS, .showsNodeCount])
                .frame(minWidth: 512, maxWidth: 1024, minHeight: 384, maxHeight: 768)
        #elseif os(iOS)
        SpriteView(scene: GameOne(), debugOptions: [.showsFPS, .showsNodeCount])
                .ignoresSafeArea()
        //WebView()
        #elseif os(watchOS)
        
        VStack {
            SpriteView(scene: scene)
                    .ignoresSafeArea()
            
            HStack {
                let btnInfo = [
                    ("arrow.right", CGVector(dx: 20, dy: 0)),
                    ("arrow.left", CGVector(dx: -20, dy: 0)),
                    ("arrow.up", CGVector(dx: 0, dy: 20)),
                    ("arrow.down", CGVector(dx: 0, dy: -20))
                ]

                ForEach(btnInfo, id:\.self.0) { (str, vec) in
                    Button {
                        scene.doWatchThing(vector: vec)
                    } label: {
                        Image(systemName: str)
                    }
                }
                
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
    
    #if os(iOS)
    let manager = CMMotionManager()
    #endif
    
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
        
        #if os(iOS)
        manager.startAccelerometerUpdates()
        #endif
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
        
        for node in background.children {
            if node.position.x < -480 {
                node.removeFromParent()
            }
        }
        
        #if os(iOS)
        if let accelerometerData = manager.accelerometerData {
            let dx = CGFloat(accelerometerData.acceleration.y) * 100
            let dy = CGFloat(accelerometerData.acceleration.x) * 100
            player.position.x -= dx
            player.position.y += dy
        }
        #endif
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
        self.background.addChild(sprite)
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
    func doWatchThing(vector: CGVector) {
        player.physicsBody?.velocity = vector
    }
    #endif
        

}

extension GameOne: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA == player {
            playerHit(nodeB)
        } else if nodeB == player {
            playerHit(nodeA)
        }
    }
    
    func playerHit(_ node: SKNode) {
        
        run(explosionSound)
        music.removeFromParent()
        
        gameOver.zPosition = 3
        gameOver.run(.sequence([.wait(forDuration: 1, withRange: 1), .removeFromParent()]))
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
            self.timer?.invalidate()
            self.removeAllChildren()
            self.background.removeAllChildren()
            self.sceneDidLoad()
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
#if os(iOS)
struct WebView: UIViewRepresentable {
    let url: URL = URL(string: "https://mightycounty.top")!
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
#endif
