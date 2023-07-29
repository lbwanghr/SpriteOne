import SpriteKit

/// Generate animation library including all characters's all animations by direction and action.
func resolveRawAnimationPics() -> [String: AnimationSet] {
    var result = [String: AnimationSet]()
    for name in roleTypeNames {
        result[name] = resolveRawAnimationPic(named: name)!
    }
    return result
}

func resolveRawAnimationPic(named: String) -> AnimationSet? {
    guard let input = UIImage(named: named) else { return nil }
    guard let ciImg = CIImage(image: input) else { return nil }
    let context = CIContext()
    var result = AnimationSet()
    var directionOffset = 0
    for direction in Direction.allCases {
        result[direction] = [AnimationType: [SKTexture]]()
        var animationTypeOffset = 0
        for animationType in AnimationType.allCases {
            result[direction]![animationType] = [SKTexture]()
            for index in 0 ..< 4 {
                let cgImg = context.createCGImage(ciImg, from: CGRect(x: (animationTypeOffset * 4 + index) * 32, y: directionOffset * 32, width: 32, height: 32))!
                let texture = SKTexture(cgImage: cgImg)
                result[direction]![animationType]!.append(texture)
            }
            animationTypeOffset += 1
        }
        directionOffset += 1
    }
    return result
}


