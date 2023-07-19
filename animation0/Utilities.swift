//
//  Utilities.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/20.
//

import Foundation

extension Date {
    static func formattedTimeStamp() -> String {
        let now = Date.now
        let ms = CLongLong((now.timeIntervalSince1970 * 1000).rounded()).description.suffix(3)
        return "\(now.formatted(date: .omitted, time: .standard)).\(ms)"
    }

    static func printWithTimeStamp(_ str: String) {
        print("\(Date.formattedTimeStamp()): \(str)")
    }
}
