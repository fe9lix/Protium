import Foundation

// See: https://github.com/casademora/CoreHTTP/blob/master/Library/Logging.swift
// and: https://gist.github.com/Abizern/a81f31a75e1ad98ff80d

enum LogLevel: String {
    case debug
    case info
    case warn
    case error
    case fatal
}

protocol Logger {
    func log<T>(_ object: @autoclosure () -> T, _ level: LogLevel, _ file: String, _ function: String, _ line: Int)
}

extension Logger {
    func log<T>(_ object: @autoclosure () -> T, _ level: LogLevel = .debug, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        let value = object()
        let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        let queue = Thread.isMainThread ? "UI" : "BG"
        
        print("\(level.rawValue.uppercased()) <\(queue)> \(fileURL) \(function)[\(line)]: " + String(reflecting: value))
    }
}

struct PrintLogger: Logger {}

var currentLogLevel: LogLevel = .debug
var currentLogger: Logger = PrintLogger()

func log<T>(_ object: @autoclosure () -> T, _ level: LogLevel = .debug, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
    currentLogger.log(object, level, file, function, line)
    #endif
}
