// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import Foundation
import SwiftUI

@Observable

class LinkState {
  // Convenience initializer
  init(_ configDictionary: [String: Any]? = nil, isolate: Bool = false) {
    self.configDictionary = configDictionary ?? [:]

    if isolate {
#if DEBUG
      allInterfaces = Interfaces.all(.sync)
      configFilePath = FileManager.default.temporaryDirectory
        .appendingPathComponent("LinkLiarLocal.isolation.json")
        .path
      isolated = true
#endif
    }
  }

  // GUI
  var wantsToQuit = false
  var manualActionMessage: String?
  var manualActionError: String?
  var manualActionInProgress = false
  var version: Version = {
    Version(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")
  }()

  // Network
  var allInterfaces = [Interface]()
  var originalMACsByBSD = [String: MAC]()

  // Paths

  var configFilePath: String = Paths.configFile
  var isolated: Bool = false

  // Settings

  /// Holds the raw configuration file as Dictionary.
  var configDictionary: [String: Any] = [:]

  /// Convenience wrapper for reading the configuration.
  var config: Config.Reader {
    Config.Reader(configDictionary)
  }

  // Derived
  var warnAboutLeakage: Bool {
    self.allInterfaces.contains(where: { $0.hasOriginalMAC })
  }

  func originalMAC(for interface: Interface) -> MAC {
    let bsdName = interface.bsd.name

    if let cachedOriginal = originalMACsByBSD[bsdName] {
      return cachedOriginal
    }

    originalMACsByBSD[bsdName] = interface.hardMAC
    return interface.hardMAC
  }

  func preserveOriginalMACs(in interfaces: [Interface]) -> [Interface] {
    interfaces.forEach { interface in
      let original = originalMAC(for: interface)
      interface.applyOriginalMACOverride(original)
    }

    return interfaces
  }
}
