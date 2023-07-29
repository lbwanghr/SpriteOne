import Foundation

func printWithTimeStamp(_ str: String) { print("\(formattedTimeStamp()): \(str)") }

func formattedTimeStamp() -> String {
    let now = Date.now
    let ms = CLongLong((now.timeIntervalSince1970 * 1000).rounded()).description.suffix(3)
    return "\(now.formatted(date: .omitted, time: .standard)).\(ms)"
}
