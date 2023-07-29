import SpriteKit

class GameScene: SKScene {
    let role = GameRole()
    var bg = SKNode()
    var moveWheel = SKNode()
    var actionBtnSet = SKNode()
    var touchedNodes = [UITouch: SKNode]() // Record every touch which binding to a node.
    
    override func sceneDidLoad() {
        size = resolution;                          scaleMode = .aspectFit
        bg = generateBackground();                  addChild(bg)
        moveWheel = generateMoveWheel();            addChild(moveWheel)
        actionBtnSet = generateActionButtons();     addChild(actionBtnSet)
        role.configuration();                       addChild(role)
        
    }
    
    override func didMove(to view: SKView) { self.view?.isMultipleTouchEnabled = true }
    
    override func update(_ currentTime: TimeInterval) {
        if !role.isPlaying { role.texture = role.idleTexture }
        
        fixReBoundAfterHitTree()
        fixScreenOffset()

        role.lastPosition = role.position
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            guard let node = nodes.first else { continue }
            if let name = node.name {
                touchedNodes[touch] = node  // Record the touched node with UITouch key.
                if let actionType = ActionType(rawValue: name){
                    if actionType == .changeRole {
                        role.removeAllActions()
                        role.roleType = roleTypeNames.randomElement()!
                    } else {
                        let animationType = AnimationType(rawValue: actionType.rawValue)!
                        role.playActionAnimation(animationType: animationType)
                    }
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let node = touchedNodes[touch] {
                if let name = node.name {
                    if name == "smallCircle" {
                        node.position = wheelPosition
                        role.physicsBody?.velocity = .zero
                    }
                }
                touchedNodes.removeValue(forKey: touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touchedNodes[touch]?.name == "smallCircle" {
                let location = touch.location(in: self)
                let r = wheelRadius.bigCircle - wheelRadius.smallCircle
                let delta = location - wheelPosition
//                print("\(delta.debugDescription)")
                let absoluteDelta = sqrt(delta.x * delta.x + delta.y * delta.y)
                // when touch exceed bigCircle area, limit it to this area
                let limitedDelta = absoluteDelta > r ? delta * (r / absoluteDelta) : delta
                touchedNodes[touch]!.position = wheelPosition + limitedDelta
                let velocity = CGVector(dx: limitedDelta.x, dy: limitedDelta.y)
                role.physicsBody?.velocity = velocity
                role.facing = velocity.toDirection()
                if !role.isPlaying { role.playMoveAnimation() }
                
            }
            
        }
    }
    

    
    /// Generate background
    /// - Tiles are attached to a sknode called bg.
    /// - Note: sknode has no anchorPoint property, that means the anchorPoint is .zero.
    func generateBackground() -> SKNode {
        let root = SKNode()
        let (rows, cols) = (Int(bgSize.height) / 16, Int(bgSize.width) / 16)
        let tileNames = ["Dirt", "Grass1", "Grass2"]
        let bgTree = "Tree"

        // Generate tiles(designate tile's anchorPoint to .zero)
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let tile = SKSpriteNode(imageNamed: tileNames.randomElement()!)
                tile.anchorPoint = .zero
                tile.position = CGPoint(x: col * 16, y: row * 16)
                tile.zPosition = -1
                root.addChild(tile)
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
            root.addChild(tree)
        }
        return root
    }
    
    func generateMoveWheel() -> SKNode {
        let root = SKNode()
        root.alpha = 0.5
        let bigCircle = SKShapeNode(circleOfRadius: wheelRadius.bigCircle)
        bigCircle.position = wheelPosition
        bigCircle.fillColor = .lightGray
        let smallCircle = SKShapeNode(circleOfRadius: wheelRadius.smallCircle)
        smallCircle.position = wheelPosition
        smallCircle.fillColor = .darkGray
        smallCircle.name = "smallCircle"
        root.addChild(bigCircle)
        root.addChild(smallCircle)
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
    
    /// Fix Bugs: momentum conservation causes role rebounding after hitting a tree/
    func fixReBoundAfterHitTree() {
        if role.physicsBody?.velocity.toDirection() != role.facing {
            for (touch, node) in touchedNodes {
                if node.name == "smallCircle" {
                    let location = touch.location(in: self)
                    let r = wheelRadius.bigCircle - wheelRadius.smallCircle
                    let delta = location - wheelPosition
                    print("\(delta.debugDescription)")
                    let absoluteDelta = sqrt(delta.x * delta.x + delta.y * delta.y)
                    // when touch exceed bigCircle area, limit it to this area
                    let limitedDelta = absoluteDelta > r ? delta * (r / absoluteDelta) : delta
                    touchedNodes[touch]!.position = wheelPosition + limitedDelta
                    let velocity = CGVector(dx: limitedDelta.x, dy: limitedDelta.y)
                    role.physicsBody?.velocity = velocity
                    role.facing = velocity.toDirection()
                    if !role.isPlaying { role.playMoveAnimation() }
                }
            }
        }
    }
    
    func fixScreenOffset() {
        let (w1, h1) = (bgSize.width, bgSize.height)
        let (w2, h2) = (resolution.width, resolution.height)
        
        let (rminx, rmaxx, rminy, rmaxy) = (0.0, w2, 0.0, h2)
        if role.position.x < rminx { role.position.x = rminx }
        else if role.position.x > rmaxx { role.position.x = rmaxx }
        if role.position.y < rminy { role.position.y = rminy }
        else if role.position.y > rmaxy { role.position.y = rmaxy }
        
        let (bgMinX, bgMaxX, bgMinY, bgMaxY) = (-w1 + w2, 0.0, -h1 + h2, 0.0)
        if bg.position.x < bgMinX { bg.position.x = bgMinX }
        else if bg.position.x > bgMaxX { bg.position.x = bgMaxX }
        if bg.position.y < bgMinY { bg.position.y = bgMinY }
        else if bg.position.y > bgMaxY { bg.position.y = bgMaxY }
        
        let offset = role.position - role.lastPosition
        let roleGlobalPosition = role.position - bg.position
    
        let (rgx, rgy) = (roleGlobalPosition.x, roleGlobalPosition.y)
        let (xflag1, xflag2, yflag1, yflag2) = (w2 / 2, w1 - w2 / 2, h2 / 2, h1 - h2 / 2)
        enum Region { case r1, r2, r3, r4, r5, r6, r7, r8, r9 }
        var region: Region? = nil
        
        let (xrange1, xrange2, xrange3) = (0 ..< xflag1, xflag1 ..< xflag2, xflag2 ..< w1)
        let (yrange1, yrange2, yrange3) = (0 ..< yflag1, yflag1 ..< yflag2, yflag2 ..< h1)
        switch(rgx, rgy) {
        case (xrange1, yrange3): region = .r1
        case (xrange2, yrange3): region = .r2
        case (xrange3, yrange3): region = .r3
        case (xrange1, yrange2): region = .r8
        case (xrange2, yrange2): region = .r9
        case (xrange3, yrange2): region = .r4
        case (xrange1, yrange1): region = .r7
        case (xrange2, yrange1): region = .r6
        case (xrange3, yrange1): region = .r5
        default: break
        }
        
        switch region {
        case .r2, .r6: bg.position.x -= offset.x; role.position.x -= offset.x
        case .r4, .r8: bg.position.y -= offset.y; role.position.y -= offset.y
        case .r9: bg.position -= offset; role.position -= offset
        default: break
        }
    }

}

