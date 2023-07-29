import Foundation

extension CGPoint {
    static func + (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func - (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func * (_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint { CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
    static func * (_ lhs: CGFloat, _ rhs: CGPoint) -> CGPoint { CGPoint(x: lhs * rhs.x, y: lhs * rhs.y) }
    static func + (_ lhs: CGPoint, _ rhs: CGVector) -> CGPoint { CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy) }
    static func <= (_ lhs: CGPoint, _ rhs: CGPoint) -> Bool { lhs.x <= rhs.x && lhs.y <= rhs.y}
    static func -= (_ lhs: inout CGPoint, _ rhs: CGPoint) { lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
}
