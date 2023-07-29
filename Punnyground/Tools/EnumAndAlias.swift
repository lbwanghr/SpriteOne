import SpriteKit

enum Direction: CaseIterable { case southwest, west, northwest, north, northeast, east, southeast, south }
enum AnimationType: String, CaseIterable { case move, slash, shoot, cast, hurt, dead }
enum ActionType: String, CaseIterable { case slash, shoot, cast, hurt, dead, changeRole }

typealias AnimationSet = [Direction: [AnimationType: [SKTexture]]]
