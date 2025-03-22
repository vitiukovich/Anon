//
//  Logger.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/22/25.
//

import Foundation

enum LogLevel: String {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case debug = "🔍 DEBUG"
}

struct Logger {
    static var isEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static func log(_ message: @autoclosure () -> Any, level: LogLevel = .debug, file: String = #file, line: Int = #line, function: String = #function) {
        guard isEnabled else { return }

        let fileName = (file as NSString).lastPathComponent
        let timestamp = Logger.timestamp()
        let fullMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function) → \(message())"

        print(fullMessage)
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
