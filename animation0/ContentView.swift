//
//  ContentView.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/7.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        VStack {
            SpriteView(scene: GameView())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

class GameView: SKScene {
    let bg = SKSpriteNode(imageNamed: "giphy1")
    var pigSet: [SKTexture] = []
    override func sceneDidLoad() {
        self.size = CGSize(width: 256, height: 256)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        bg.size = CGSize(width: 256, height: 256)
        self.addChild(bg)
        for i in 1...8 {
            pigSet.append(SKTexture(imageNamed: "giphy\(i)"))
        }
        bg.run(.repeat(.animate(with: pigSet, timePerFrame: 0.125), count: 5))
    }
    override func update(_ currentTime: TimeInterval) {

    }
}
