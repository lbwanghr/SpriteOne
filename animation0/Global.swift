//
//  Config.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/17.
//

import Foundation

// Global single instance of DataSource, LoadScene, GameScene.
let dataSource = DataSource()
let loadScene = LoadScene()
let gameScene = GameScene()

// Global configurations
let resolution = CGSize(width: 384, height: 256)
let btnSize = CGSize(width: 28, height: 28)
let btnInterval = CGFloat(40)
let moveBtnPosition = CGPoint(x: 0, y: -100)
let actionBtnPosition = CGPoint(x: 0, y: -64)
let timePerFrame = 0.1
let moveDuration = 0.4
let moveSpeed = 5.0
let numberOfTree = 10
let btnAlpha = 0.6

//let characterAssets = ["Archer-Green", "Archer-Purple", "Character-Base", "Mage-Cyan", "Mage-Red", "Soldier-Blue", "Soldier-Red", "Soldier-Yellow", "Warrior-Blue", "Warrior-Red", "Human-Soldier-Cyan", "Human-Soldier-Red", "Human-Worker-Cyan", "Human-Worker-Red", "Orc-Grunt", "Orc-Peon-Cyan", "Orc-Peon-Red", "Orc-Soldier-Cyan", "Orc-Soldier-Red"]

let characterAssets = ["Archer-Green", "Orc-Soldier-Red"]


