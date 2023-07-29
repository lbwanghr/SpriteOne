import Foundation

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
