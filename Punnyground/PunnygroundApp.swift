//
//  animation0App.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/7.
//

import SwiftUI
import SpriteKit

@main
struct PunnygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            SpriteView(scene: gameScene)
        }
        .ignoresSafeArea()
    }
}

// Global single instance
let animations = resolveRawAnimationPics()
let gameScene = GameScene()

// Global configurations
let resolution = CGSize(width: 512, height: 288)
let bgSize = CGSize(width: 544, height: 320)
let btnSize = CGSize(width: 32, height: 32)
let btnInterval = CGFloat(40)
let wheelPosition = CGPoint(x: 56, y: 48)
let wheelRadius:(bigCircle: CGFloat, smallCircle: CGFloat) = (36, 14)
let actionBtnPosition = CGPoint(x: 320, y: 48)
let roleStartPoint = CGPoint(x: resolution.width / 2, y: resolution.height / 2)
let timePerFrame = 0.1
let moveDuration = 0.4
let moveSpeed = 5.0
let numberOfTree = 10
let btnAlpha = 0.6

//let characterNames = ["Archer-Green", "Archer-Purple", "Character-Base", "Mage-Cyan", "Mage-Red", "Soldier-Blue", "Soldier-Red", "Soldier-Yellow", "Warrior-Blue", "Warrior-Red", "Human-Soldier-Cyan", "Human-Soldier-Red", "Human-Worker-Cyan", "Human-Worker-Red", "Orc-Grunt", "Orc-Peon-Cyan", "Orc-Peon-Red", "Orc-Soldier-Cyan", "Orc-Soldier-Red"]
let roleTypeNames = ["Archer-Green", "Orc-Soldier-Red"]
