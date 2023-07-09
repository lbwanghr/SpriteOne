//
//  GameTwo.swift
//  SpriteTwo
//
//  Created by Haoran Wang on 2023/7/9.
//

import SwiftUI
import SpriteKit

class GameTwo: SKScene {
    let bgSize = CGSize(width: 1024, height: 768)
    let bg = SKSpriteNode(imageNamed: "background-leaves")
    let scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let timeLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let music = SKAudioNode(fileNamed: "truth-in-the-stones")
    var level = 1
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    var startTime = 0.0
    var isGameRunning = true
    
    
    override func sceneDidLoad() {
        self.size = bgSize
        self.scaleMode = .aspectFit
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bg.size = bgSize
        bg.name = "bg"
        bg.zPosition = -1
        self.addChild(bg)
        scoreLabel.position = CGPoint(x: -480, y: 330)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        timeLabel.position = CGPoint(x: 480, y: 330)
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.zPosition = 1
        self.addChild(timeLabel)
        self.addChild(music)
        createGrid()
        restart()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameRunning {
            if startTime == 0 {
                startTime = currentTime
            }
            
            let timePassed = currentTime - startTime
            let remainingTime = Int(ceil(10 - timePassed))
            timeLabel.text = "TIME: \(remainingTime)"
            timeLabel.alpha = 1
            if remainingTime <= 0 {
                isGameRunning = false
                let gameOver = SKSpriteNode(imageNamed: "gameOver1")
                gameOver.zPosition = 100
                gameOver.run(.sequence([.wait(forDuration: 3), .removeFromParent()]))
                self.addChild(gameOver)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.restart()
                }
            }
        } else {
            timeLabel.alpha = 0
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameRunning else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = bg.nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "correct" {
            correctAnswer(node: tapped)
        } else if tapped.name == "wrong" {
            wrongAnswer(node: tapped)
        }
    }
    
    func restart() {
        level = 0
        score = 0
        startTime = 0
        isGameRunning = true
        createLevel()
    }
    
    func createGrid() {
        let xOffset = -440
        let yOffset = -320
        for row in 0 ..< 8 {
            for col in 0 ..< 12 {
                let item  = SKSpriteNode(imageNamed: "elephant")
                item.position = CGPoint(x: xOffset + col * 80, y: yOffset + row * 80)
                item.zPosition = 0
                bg.addChild(item)
            }
        }
        
    }
    
    func createLevel() {
        var itemsToShow = 5 + (level * 4)
        itemsToShow = min(itemsToShow, 96)
        let items = bg.children
        let shuffled = items.shuffled() as! [SKSpriteNode]
        for item in shuffled {
            item.alpha = 0
        }
        let animals = ["elephant", "giraffe", "hippo", "monkey", "panda", "parrot", "penguin", "pig", "rabbit", "snake"]
        var shuffledAnimals = animals.shuffled()
        
        let correct = shuffledAnimals.removeLast()
        var showAnimals: [String] = []
        var placingAnimal = 0
        var numUsed = 0
        for _ in 1 ..< itemsToShow {
            numUsed += 1
            showAnimals.append(shuffledAnimals[placingAnimal])
            if numUsed == 2 {
                numUsed = 0
                placingAnimal += 1
            }
            if placingAnimal == shuffledAnimals.count {
                placingAnimal = 0
            }
        }
        
        for (index, animal) in showAnimals.enumerated() {
            let item = shuffled[index]
            item.texture = SKTexture(imageNamed: animal)
            item.run(.fadeIn(withDuration: 0.5))
            //item.alpha = 1
            item.name = "wrong"
        }
        shuffled.last?.texture = SKTexture(imageNamed: correct)
        shuffled.last?.run(.fadeIn(withDuration: 0.5))
//        shuffled.last?.alpha = 1
        shuffled.last?.name = "correct"
        
        isUserInteractionEnabled = true
    }
    
    func correctAnswer(node: SKNode) {
        startTime = 0
        score += 1
        node.run(.playSoundFileNamed("correct-1", waitForCompletion: false))
        
        let fade = SKAction.fadeOut(withDuration: 0.5)
        for child in bg.children {
            guard child.name == "wrong" else { continue }
            child.run(fade)
        }
        
        let scaleUp = SKAction.scale(to: 2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1, duration: 0.5)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        node.run(sequence)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.level += 1
            self.createLevel()
        }
        
        isUserInteractionEnabled = false
    }
    
    func wrongAnswer(node: SKNode) {
        score -= 1
        node.run(.playSoundFileNamed("wrong-1", waitForCompletion: false))
        
        let wrong = SKSpriteNode(imageNamed: "wrong")
        wrong.position = node.position
        wrong.zPosition = 5
        self.addChild(wrong)
        wrong.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))
    }
}

#Preview {
    SpriteView(scene: GameTwo())
        .ignoresSafeArea()
}
