//
//  GameFour.swift
//  SpriteFour
//
//  Created by Haoran Wang on 2023/7/11.
//

import Foundation
import SpriteKit

class GameFour: SKScene {
    let bgSize = CGSize(width: 1024, height: 768)
    let bg = SKSpriteNode(imageNamed: "night")
    let scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
    let timer = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 500, height: 40))
    let music = SKAudioNode(fileNamed: "alien-restaurant")
    
    var cols: [[Item]] = []
    let itemSize: CGFloat = 50
    let itemsPerColumn = 12
    let itemsPerRow = 18
    
    var currentMatches = Set<Item>()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    var gameStartTime: TimeInterval?
    var isGameOver = false
    
    
    override func sceneDidLoad() {
        self.size = bgSize
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        
        bg.zPosition = -2
        self.addChild(bg)
        
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 80)
        self.addChild(scoreLabel)
        score = 0
        
        timer.fillColor = .green
        timer.strokeColor = .clear
        timer.position = CGPoint(x: frame.minX + 70, y: frame.maxY - 80)
        self.addChild(timer)
        
        self.addChild(music)
        
        createGrid()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let gameStartTime = gameStartTime {
            let elapsed = currentTime - gameStartTime
            let remaining = 100 - elapsed
            timer.xScale = max(0, CGFloat(remaining) / 100)
            if remaining <= 0 {
                endGame()
            }
        } else {
            gameStartTime = currentTime
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let tappedItem = item(at: location) else { return }
        self.run(.playSoundFileNamed("zap", waitForCompletion: false))
        currentMatches.removeAll()
        
        if tappedItem.name == "bomb" {
            triggerSpecialItem(tappedItem)
        }
        
        match(item: tappedItem)
        isUserInteractionEnabled = false
        removeMatches()
        moveDown()
        adjustScore()
        
    }
    
    func position(for item: Item) -> CGPoint {
        let xOffset: CGFloat = -430
        let yOffset: CGFloat = -300
        let x = xOffset + itemSize * CGFloat(item.col)
        let y = yOffset + itemSize * CGFloat(item.row)
        return CGPoint(x: x, y: y)
    }
    
    func createItem(row: Int, col: Int, startOffScreen: Bool = false) -> Item {
        let itemColors = ["beige", "blue", "gray", "green", "pink", "purple", "yellow"]
        let itemNames = itemColors.map { "alien-\($0)" }
        let itemName = startOffScreen && Int.random(in: 0...24) == 0 ? "bomb" : itemNames.randomElement()!
        let item = Item(imageNamed: itemName)
        item.name = itemName
        item.row = row
        item.col = col
        if startOffScreen {
            let finalPosition = position(for: item)
            item.position = finalPosition
            item.position.y += 600
            item.run(.move(to: finalPosition, duration: 0.4)) {
                self.isUserInteractionEnabled = true
            }
        } else {
            item.position = position(for: item)
        }
        
        self.addChild(item)
        return item
    }
    
    func createGrid() {
        for x in 0 ..< itemsPerRow {
            var col = [Item]()
            for y in 0 ..< itemsPerColumn {
                let item = createItem(row: y, col: x)
                col.append(item)
            }
            cols.append(col)
        }
    }
    
    func item(at point: CGPoint) -> Item? {
        let items = nodes(at: point).compactMap{ $0 as? Item }
        return items.first
    }
    
    func match(item original: Item) {
        var checkItems = [Item?]()
        currentMatches.insert(original)
        let pos = original.position
        
        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y - itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y + itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x - itemSize, y: pos.y)))
        checkItems.append(item(at: CGPoint(x: pos.x + itemSize, y: pos.y)))
        
        for case let check? in checkItems {
            if currentMatches.contains(check) { continue }
            if check.name == original.name || original.name == "bomb" {
                match(item: check)
            }
        }
    }
    
    func removeMatches() {
        let sortedMatches = currentMatches.sorted { $0.row > $1.row }
        for item in sortedMatches {
            cols[item.col].remove(at: item.row)
            item.removeFromParent()
        }
    }
    
    func moveDown() {
        for (columnIndex, col) in cols.enumerated() {
            for (rowIndex, item) in col.enumerated() {
                item.row = rowIndex
                item.run(.move(to: position(for: item), duration: 0.1))
            }
            
            while cols[columnIndex].count < itemsPerColumn {
                let item = createItem(row: cols[columnIndex].count, col: columnIndex, startOffScreen: true)
                cols[columnIndex].append(item)
            }
        }
    }
    
    func triggerSpecialItem(_ item: Item) {
        self.run(.playSoundFileNamed("smart-bomb", waitForCompletion: false))
        let flash = SKSpriteNode(color: .white, size: self.size)
        flash.zPosition = 1
        self.addChild(flash)
        flash.run(.fadeOut(withDuration: 0.2)) {
            flash.removeFromParent()
        }
    }
    
    func penalizePlayer() {
        gameStartTime? -= 10
    }
    
    func adjustScore() {
        let newScore = currentMatches.count
        if newScore == 1 {
            penalizePlayer()
        } else if newScore == 2 {
            
        } else {
            let matchCount = min(newScore, 16)
            let scoreToAdd = pow(2, Double(matchCount))
            
            score += Int(scoreToAdd)
        }
    }
    
    func endGame() {
        guard !isGameOver else { return }
        isGameOver = true
        let gameOver = SKSpriteNode(imageNamed: "game-over-1")
        gameOver.zPosition = 100
        self.addChild(gameOver)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.view?.presentScene(GameFour(), transition: .doorway(withDuration: 1))
        }
    }
}

class Item: SKSpriteNode {
    var row = -1
    var col = -1
    
}
