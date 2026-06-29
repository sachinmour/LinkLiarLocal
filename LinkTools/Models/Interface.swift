// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import CoreWLAN
import Foundation

// Because the soft-MAC is queried asynchronously.
// We need SwiftUI to know that the Interface instance
// may change its properties at some point in the future.
@Observable

/// A local ethernet network interface. E.g. Wi-Fi, LAN port, or ethernet-dongle.
///
class Interface: Identifiable {
  // MARK: Class Methods

  init?(bsd: BSD,
        hardMAC: MAC,
        name: String = "?",
        kind: String = "?",
        resolving: Interface.SoftMACResolving = .sync,
        stubSoftMAC: MAC? = nil) {
    self.bsd = bsd
    self.hardMAC = hardMAC
    self.rawName = name
    self.kind = kind
    self.resolving = resolving
    self.stubSoftMAC = stubSoftMAC
    querySoftMAC()
  }

  // MARK: Instance Properties

  /// Conforming to `Identifiable`.
  var id: String { bsd.name }

  let bsd: BSD
  private(set) var hardMAC: MAC
  let kind: String

  // Not sure why, but some Ethernet interfaces have this redundantly in their name.
  var name: String {
    rawName
      .replacingOccurrences(of: "\\(en[0-9]+\\)", with: "", options: .regularExpression)
      .trimmingCharacters(in: .whitespaces)
  }

  var softMAC: MAC? {
    _softMAC ?? stubSoftMAC
  }

  var softOUI: OUI {
    OUI(softMAC!.prefix)!
  }

  var hasOriginalMAC: Bool {
    hardMAC == softMAC
  }

  var isSpoofable: Bool {
    // Only properly queried Interfaces have knowledge of spoofability.
    if kind.isEmpty { return false }
    if name.isEmpty { return false }

    // You can only change MAC addresses of Ethernet and Wi-Fi adapters
    if (["Ethernet", "IEEE80211"].firstIndex(of: kind) ) == nil { return false }

    // Bluetooth can also be filtered out
    if name.contains("tooth") { return false }

    // iPhones etc. are not spoofable either
    if name.contains("iPhone") { return false }
    if name.contains("iPad") { return false }
    if name.contains("iPod") { return false }

    // Internal Thunderbolt interfaces cannot be spoofed either
    if name.contains("Thunderbolt 1") { return false }
    if name.contains("Thunderbolt 2") { return false }
    if name.contains("Thunderbolt 3") { return false }
    if name.contains("Thunderbolt 4") { return false }
    if name.contains("Thunderbolt 5") { return false }

    return true
  }

  var isWifi: Bool {
    CWWiFiClient.shared().interface(withName: bsd.name) != nil
  }

  var isWiFiHardware: Bool {
    kind == "IEEE80211"
  }

  var iconName: String {
    if isWiFiHardware { return "wifi" }

    return "cable.connector.horizontal"
  }

  // MARK: Private Instance Properties

  private var _softMAC: MAC?
  private let rawName: String
  private let resolving: SoftMACResolving
  private let stubSoftMAC: MAC?

  // MARK: Private Instance Methods

  /// Asks ``Ifconfig`` to fetch the soft MAC of this Interface.
  /// The answer is stored in the softMAC property.
  /// This can be done synchronously or asynchronously.
  func querySoftMAC() {
    if resolving == .sync {
      guard let address = Ifconfig.Reader(bsd.name).softMAC() else { return }
      self._softMAC = address

    } else if resolving == .async {
      Ifconfig.Reader(bsd.name).softMAC(callback: { potentialAddress in
        guard let address = potentialAddress else { return }

        DispatchQueue.main.async {
//          Log.debug("Setting softMAC to \(address.address)")
          self._softMAC = address
        }
      })
    }
  }

  func applyOriginalMACOverride(_ mac: MAC) {
    hardMAC = mac
  }
}

extension Interface: Comparable {
  static func == (lhs: Interface, rhs: Interface) -> Bool {
    lhs.bsd == rhs.bsd
  }

  static func < (lhs: Interface, rhs: Interface) -> Bool {
    lhs.bsd < rhs.bsd
  }
}

extension Interface {
  enum SoftMACResolving: String {
    case sync
    case async
    case none
  }
}
