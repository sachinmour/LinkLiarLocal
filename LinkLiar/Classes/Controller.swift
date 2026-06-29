// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import Cocoa
import CoreWLAN
import Foundation
import Security
import SwiftUI

class Controller {
  // MARK: Class Methods

  static func refreshInterfaces(state: LinkState) {
    Log.debug("Refreshing Interfaces...")
    state.allInterfaces = state.preserveOriginalMACs(in: Interfaces.all(.sync))
  }

  static func queryInterfaces(state: LinkState) {
    refreshInterfaces(state: state)
  }

  static func wantsToQuit(_ state: LinkState) {
    if state.manualActionInProgress {
      state.wantsToQuit = true
    } else {
      quitForReal()
    }
  }

  static func wantsToStay(_ state: LinkState) {
    state.wantsToQuit = false
  }

  static func quitForReal() {
    NSApplication.shared.terminate(nil)
  }

  static func troubleshoot(state: LinkState) {
    refreshInterfaces(state: state)
  }
}

@MainActor
enum SettingsWindowPresenter {
  private static var window: NSWindow?

  static func show(state: LinkState) {
    Log.debug("Settings window requested")

    if let existingWindow = window {
      present(existingWindow)
      return
    }

    let hostingController = NSHostingController(rootView: SettingsView().environment(state))
    let settingsWindow = NSWindow(
      contentRect: NSRect(origin: .zero, size: SettingsWindowMetrics.initialSize),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )

    settingsWindow.title = "LinkLiar Local Settings"
    settingsWindow.contentMinSize = SettingsWindowMetrics.minimumSize
    settingsWindow.contentViewController = hostingController
    settingsWindow.isReleasedWhenClosed = false
    settingsWindow.setFrameAutosaveName(SettingsWindowMetrics.autosaveName)
    settingsWindow.center()

    window = settingsWindow
    present(settingsWindow)
  }

  private static func present(_ settingsWindow: NSWindow) {
    if settingsWindow.isMiniaturized {
      settingsWindow.deminiaturize(nil)
    }

    settingsWindow.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}

enum AdminCommandRunner {
  private struct ApprovedCommand: Equatable {
    let path: String
    let arguments: [String]

    var commandString: String {
      ([path] + arguments).joined(separator: " ")
    }
  }

  enum CommandError: Error, LocalizedError, Equatable {
    case invalidInterfaceName(String)
    case invalidMACAddress(String)
    case scriptFailed(String)

    var errorDescription: String? {
      switch self {
      case let .invalidInterfaceName(name):
        return "Invalid interface name: \(name)"
      case let .invalidMACAddress(address):
        return "Invalid MAC address: \(address)"
      case let .scriptFailed(output):
        return output.isEmpty ? "The admin command failed." : output
      }
    }
  }

  static func runIfconfigEther(bsdName: String, mac: MAC) throws {
    let command = try buildIfconfigEtherCommand(bsdName: bsdName, mac: mac)
    try runWithAdministratorPrivileges(command)
  }

#if DEBUG
  static func approvedIfconfigEtherCommandDescription(bsdName: String, mac: MAC) throws -> (path: String, arguments: [String]) {
    let command = try buildIfconfigEtherCommand(bsdName: bsdName, mac: mac)
    return (command.path, command.arguments)
  }
#endif

  private static func buildIfconfigEtherCommand(bsdName: String, mac: MAC) throws -> ApprovedCommand {
    guard bsdName.range(of: #"^en[0-9]+$"#, options: .regularExpression) != nil else {
      throw CommandError.invalidInterfaceName(bsdName)
    }

    guard MAC(mac.address) != nil else {
      throw CommandError.invalidMACAddress(mac.address)
    }

    return ApprovedCommand(path: Paths.ifconfigCLI, arguments: [bsdName, "ether", mac.address])
  }

  private static func runWithAdministratorPrivileges(_ command: ApprovedCommand) throws {
    let appleScript = """
    do shell script "\(command.commandString)" with administrator privileges
    """

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    process.arguments = ["-e", appleScript]

    let errorPipe = Pipe()
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      throw CommandError.scriptFailed(error.localizedDescription)
    }

    guard process.terminationStatus == 0 else {
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let errorString = String(data: errorData, encoding: .utf8) ?? ""
      throw CommandError.scriptFailed(errorString.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
}

enum RandomMACGenerator {
  enum GeneratorError: Error, LocalizedError {
    case randomBytesFailed
    case noVendorPrefixes

    var errorDescription: String? {
      switch self {
      case .randomBytesFailed:
        return "Could not generate secure random bytes."
      case .noVendorPrefixes:
        return "No vendor prefixes are available."
      }
    }
  }

  static func privateLocalAdmin() throws -> MAC {
    var bytes = try secureRandomBytes(count: 6)
    bytes[0] = 0x02
    return makeMAC(bytes)
  }

  static func vendorLike(config: Config.Reader) throws -> MAC {
    let candidates: [OUI]
    if config.dictionary[Config.Key.vendors.rawValue] as? [String] == nil {
      candidates = fallbackPopularOUIs
    } else {
      candidates = config.ouis.chosenPopular
    }

    guard let prefix = candidates.randomElement() else {
      throw GeneratorError.noVendorPrefixes
    }

    let suffix = try secureRandomBytes(count: 3)
    let prefixBytes = prefix.address.split(separator: ":").compactMap { UInt8($0, radix: 16) }
    guard prefixBytes.count == 3 else { throw GeneratorError.noVendorPrefixes }

    return makeMAC(prefixBytes + suffix)
  }

  static let fallbackVendorIDs = ["apple", "intel", "samsung", "cisco", "dell", "google", "netgear"]

  static var fallbackPopularOUIs: [OUI] {
    PopularOUIs.find(fallbackVendorIDs)
  }

  private static func secureRandomBytes(count: Int) throws -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    guard result == errSecSuccess else { throw GeneratorError.randomBytesFailed }
    return bytes
  }

  private static func makeMAC(_ bytes: [UInt8]) -> MAC {
    MAC(bytes.map { String(format: "%02x", $0) }.joined(separator: ":"))!
  }
}

enum MACChangeService {
  enum ChangeError: Error, LocalizedError {
    case actionInProgress
    case interfaceMissing(String)
    case interfaceNotSpoofable(String)
    case invalidMACAddress(String)
    case wifiPoweredOff(String)

    var errorDescription: String? {
      switch self {
      case .actionInProgress:
        return "A MAC change is already in progress."
      case let .interfaceMissing(name):
        return "Interface \(name) is no longer available."
      case let .interfaceNotSpoofable(name):
        return "Interface \(name) is not spoofable."
      case let .invalidMACAddress(address):
        return "Invalid MAC address: \(address)"
      case let .wifiPoweredOff(name):
        return "Turn Wi-Fi on before changing \(name)'s MAC address."
      }
    }
  }

  static func randomizePrivate(interface: Interface, state: LinkState) {
    perform(interface: interface, state: state) {
      try RandomMACGenerator.privateLocalAdmin()
    }
  }

  static func randomizeVendorLike(interface: Interface, state: LinkState) {
    let config = state.config
    perform(interface: interface, state: state) {
      try RandomMACGenerator.vendorLike(config: config)
    }
  }

  static func restoreOriginal(interface: Interface, state: LinkState) {
    let originalMAC = originalMACTarget(interface: interface, state: state)

    perform(interface: interface, state: state) {
      originalMAC
    }
  }

  static func originalMACTarget(interface: Interface, state: LinkState) -> MAC {
    state.originalMAC(for: interface)
  }

  static func setSpecific(interface: Interface, address: String, state: LinkState) {
    perform(interface: interface, state: state) {
      guard let mac = MAC(address) else { throw ChangeError.invalidMACAddress(address) }
      return mac
    }
  }

  static func validateWiFiPower(interface: Interface, isPowerOn: Bool?) throws {
    guard interface.isWiFiHardware else { return }
    guard isPowerOn == true else { throw ChangeError.wifiPoweredOff(interface.bsd.name) }
  }

  private static func perform(interface: Interface, state: LinkState, target: @escaping () throws -> MAC) {
    guard !state.manualActionInProgress else {
      state.manualActionError = ChangeError.actionInProgress.localizedDescription
      state.manualActionMessage = nil
      return
    }

    state.manualActionInProgress = true
    state.manualActionMessage = "Waiting for administrator approval..."
    state.manualActionError = nil
    state.wantsToQuit = false

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let targetMAC = try target()
        let refreshedInterfaces = Interfaces.all(.sync)

        guard let selectedInterface = refreshedInterfaces.first(where: { $0.bsd == interface.bsd }) else {
          throw ChangeError.interfaceMissing(interface.bsd.name)
        }

        guard selectedInterface.isSpoofable else {
          throw ChangeError.interfaceNotSpoofable(selectedInterface.name)
        }

        let wifiInterface = CWWiFiClient.shared().interface(withName: selectedInterface.bsd.name)
        try validateWiFiPower(interface: selectedInterface, isPowerOn: wifiInterface?.powerOn())

        if selectedInterface.isWiFiHardware {
          wifiInterface?.disassociate()
          Thread.sleep(forTimeInterval: 0.4)
        }

        Log.debug("Running approved MAC change for \(selectedInterface.bsd.name)")
        try AdminCommandRunner.runIfconfigEther(bsdName: selectedInterface.bsd.name, mac: targetMAC)
        _ = waitForCurrentMAC(bsdName: selectedInterface.bsd.name, target: targetMAC)

        DispatchQueue.main.async {
          Controller.refreshInterfaces(state: state)
          state.manualActionMessage = "\(selectedInterface.bsd.name) changed to \(targetMAC.anonymous(true))"
          state.manualActionInProgress = false
        }
      } catch {
        DispatchQueue.main.async {
          state.manualActionError = error.localizedDescription
          state.manualActionMessage = nil
          state.manualActionInProgress = false
        }
      }
    }
  }

  private static func waitForCurrentMAC(
    bsdName: String,
    target: MAC,
    timeout: TimeInterval = 2.0,
    interval: TimeInterval = 0.2
  ) -> MAC? {
    let deadline = Date().addingTimeInterval(timeout)
    var latestMAC: MAC?

    repeat {
      latestMAC = Ifconfig.Reader(bsdName).softMAC()
      if latestMAC == target { return latestMAC }
      Thread.sleep(forTimeInterval: interval)
    } while Date() < deadline

    return latestMAC
  }
}
