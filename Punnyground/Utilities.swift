//
//  Utilities.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/20.
//

import SpriteKit

enum Direction: CaseIterable { case southwest, west, northwest, north, northeast, east, southeast, south }
enum AnimationType: String, CaseIterable { case move, slash, shoot, cast, hurt, dead }
typealias AnimationSet = [Direction: [AnimationType: [SKTexture]]]
enum ActionType: String, CaseIterable { case slash, shoot, cast, hurt, dead, changeRole }

func printWithTimeStamp(_ str: String) { print("\(formattedTimeStamp()): \(str)") }

func formattedTimeStamp() -> String {
    let now = Date.now
    let ms = CLongLong((now.timeIntervalSince1970 * 1000).rounded()).description.suffix(3)
    return "\(now.formatted(date: .omitted, time: .standard)).\(ms)"
}

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

extension CGPoint {
    static func + (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func - (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func * (_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint { CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
    static func * (_ lhs: CGFloat, _ rhs: CGPoint) -> CGPoint { CGPoint(x: lhs * rhs.x, y: lhs * rhs.y) }
    static func + (_ lhs: CGPoint, _ rhs: CGVector) -> CGPoint { CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy) }
    static func <= (_ lhs: CGPoint, _ rhs: CGPoint) -> Bool { lhs.x <= rhs.x && lhs.y <= rhs.y}
    static func -= (_ lhs: inout CGPoint, _ rhs: CGPoint) { lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
}

extension CGVector {
    func toDirection() -> Direction {
        let radian = atan2(dy, dx)
        let pi = CGFloat.pi
        var direction: Direction = .south
        switch radian / pi {
        case -0.875 ..< -0.625: direction = .southwest
        case -1 ..< -0.875, 0.875 ... 1 : direction = .west
        case 0.625 ..< 0.875: direction = .northwest
        case 0.375 ..< 0.625: direction = .north
        case 0.125 ..< 0.375: direction = .northeast
        case 0 ..< 0.125, -0.125 ..< 0: direction = .east
        case -0.375 ..< -0.125: direction = .southeast
        case -0.625 ..< -0.375: direction = .south
        default: break
        }
        return direction
    }
    
    static func * (_ lhs: CGVector, _ rhs: CGFloat) -> CGVector { CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs) }
    static func / (_ lhs: CGVector, _ rhs: CGFloat) -> CGVector { lhs * (1 / rhs) }
}
