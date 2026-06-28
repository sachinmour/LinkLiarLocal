// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import Foundation
import os.log

public struct Log {
  // MARK: Class Methods

  static func debug(_ message: String, callerPath: String = #file) {
    write(message, level: .debug, callerPath: callerPath)
  }

  static func info(_ message: String, callerPath: String = #file) {
    write(message, level: .info, callerPath: callerPath)
  }

  static func error(_ message: String, callerPath: String = #file) {
    write(message, level: .error, callerPath: callerPath)
  }

  // MARK: Private Class Methods

  private static func write(_ message: String, level: OSLogType, callerPath: String) {
    guard let filename = callerPath.components(separatedBy: "/").last else {
      return write(message, level: level)
    }

    let classname = filename.components(separatedBy: ".").dropLast().joined(separator: ".")

    write("\(classname) - \(message)", level: level)
  }

  // MARK: Private Class Properties

  private static let logger = Logger(subsystem: Identifiers.gui.rawValue, category: "logger")

  // MARK: Private Class Methods

  private static func write(_ message: String, level: OSLogType) {
    let safeMessage = redacted(message)
    logger.log(level: level, "\(safeMessage, privacy: .public)")
    appendToLogfile(safeMessage, level: level)
  }

  private static func appendToLogfile(_ message: String, level: OSLogType) {
    Paths.prepareLocalStorage()

    var prefix = "UNKNOWN"

    switch level {
    case .debug: prefix = "DEBUG"
    case .info:  prefix = "INFO "
    case .error: prefix = "ERROR"
    default:     prefix = "OTHER"
    }

    let data = "\(prefix) \(message)\n".data(using: .utf8)!

    if let fileHandle = FileHandle(forWritingAtPath: Paths.debugLogFile) {
      defer { fileHandle.closeFile() }
      fileHandle.seekToEndOfFile()
      fileHandle.write(data)
    } else {
      do {
        try data.write(to: Paths.debugLogFileURL)
        Paths.prepareLocalStorage()
      } catch {
        NSLog("LinkLiar Local could not write log file: \(error)")
      }
    }
  }

  private static func redacted(_ message: String) -> String {
    message.replacingOccurrences(
      of: #"(?i)\b[0-9a-f]{2}(?::[0-9a-f]{2}){5}\b"#,
      with: "<redacted-mac>",
      options: .regularExpression
    )
  }
}
