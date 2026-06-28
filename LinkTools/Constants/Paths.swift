// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import Foundation

class Paths {
  // Class Properties

  static let configFile = defaultConfigFile

  static let configDirectory = homeDirectory.appendPath("Library/Application Support/LinkLiarLocal")
  static let configDirectoryURL = URL(fileURLWithPath: configDirectory)

  static var configFileURL: URL {
    URL(fileURLWithPath: configFile)
  }

  static let logDirectory = homeDirectory.appendPath("Library/Logs/LinkLiarLocal")
  static let logDirectoryURL = URL(fileURLWithPath: logDirectory)
  static let debugLogFile = logDirectory.appendPath("linkliar.log")
  static let debugLogFileURL = URL(fileURLWithPath: debugLogFile)

  static let ifconfigCLI = "/sbin/ifconfig"

  static func prepareLocalStorage() {
    secureDirectory(configDirectoryURL)
    secureDirectory(logDirectoryURL)
    secureFileIfPresent(configFileURL)
    secureFileIfPresent(debugLogFileURL)
  }

  static func secureConfigFile() {
    secureFileIfPresent(configFileURL)
  }

  // Private Class Properties

  private static let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
  private static let defaultConfigFile = configDirectory.appendPath("config.json")

  private static func secureDirectory(_ url: URL) {
    do {
      try FileManager.default.createDirectory(
        at: url,
        withIntermediateDirectories: true,
        attributes: [.posixPermissions: 0o700]
      )
      try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: url.path)
    } catch {
      NSLog("LinkLiar Local could not secure directory \(url.path): \(error)")
    }
  }

  private static func secureFileIfPresent(_ url: URL) {
    guard FileManager.default.fileExists(atPath: url.path) else { return }

    do {
      try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    } catch {
      NSLog("LinkLiar Local could not secure file \(url.path): \(error)")
    }
  }
}

extension String {
  func appendPath(_ string: String) -> String {
    URL(fileURLWithPath: self).appendingPathComponent(string).path
  }
}
