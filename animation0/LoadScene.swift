//
//  LoadScene.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/19.
//

import SpriteKit

class LoadScene: SKScene {
    var progressBar = SKShapeNode()
    var loadingLabel = SKLabelNode()
    var loadingText: String = "" {
        didSet {
            loadingLabel.text = loadingText
        }
    }
    
    /// sceneDidLoad before didMove
    /// - Note: sceneDidLoad could only run once but didMove could run several times
    override func sceneDidLoad() {
        size = resolution
        scaleMode = .aspectFit
        
        loadingLabel.fontSize = 32
        loadingLabel.position = CGPoint(x: resolution.width / 2, y: resolution.height / 2)
        addChild(loadingLabel)
        
        progressBar = SKShapeNode(rect: CGRect(origin: .zero, size: CGSize(width: resolution.width, height: 5)))
        progressBar.fillColor = .green
        progressBar.strokeColor = .clear
        addChild(progressBar)
        
        Thread {
            Date.printWithTimeStamp("Generating background")
            
            self.loadingText = "Generating Background..."
            dataSource.loadBackground()
//            Thread.sleep(forTimeInterval: 0.3)
            dataSource.loadProgress = 0.3
            
            Date.printWithTimeStamp("Loading animations")
            
            self.loadingText = "Loading Animations..."
            dataSource.loadAnimations()
//            Thread.sleep(forTimeInterval: 0.3)
            dataSource.loadProgress = 0.6
            
            Date.printWithTimeStamp("Loading controls")
            
            self.loadingText = "Loading Controls..."
            dataSource.loadButtons()
//            Thread.sleep(forTimeInterval: 0.3)
            dataSource.loadProgress = 1.0
            
            Date.printWithTimeStamp("Loading completed")
        }.start()

    }
    
    override func update(_ currentTime: TimeInterval) {
        progressBar.xScale = dataSource.loadProgress
        if dataSource.loadProgress == 1.0 {
            self.view?.presentScene(gameScene, transition: .fade(withDuration: 0.3))
            progressBar.alpha = 0
            loadingLabel.alpha = 0
        }
    }
}
