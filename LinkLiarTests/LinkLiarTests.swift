// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import XCTest
@testable import LinkLiar

final class LinkLiarTests: XCTestCase {
  func testUnknownLegacyKeysDoNotHideInterfacesOrSuppressWarnings() {
    let hardMAC = MAC("aa:bb:cc:dd:ee:ff")!
    let state = LinkState([
      "default": ["action": "hide"],
      hardMAC.address: [
        "action": "ignore",
        "address": "02:11:22:33:44:55",
        "legacy_network_rules": ["Cafe": "02:aa:bb:cc:dd:ee"]
      ]
    ])

    state.allInterfaces = [
      Interface(
        bsd: BSD("en0")!,
        hardMAC: hardMAC,
        name: "Wi-Fi",
        kind: "IEEE80211",
        resolving: .none,
        stubSoftMAC: hardMAC
      )!
    ]

    XCTAssertEqual(1, state.allInterfaces.count)
    XCTAssertTrue(state.warnAboutLeakage)
  }

  func testConcurrentMACChangesAreRefusedBeforePrompt() {
    let state = LinkState()
    let interface = Interface(
      bsd: BSD("en0")!,
      hardMAC: MAC("aa:bb:cc:dd:ee:ff")!,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: MAC("aa:bb:cc:dd:ee:ff")!
    )!

    state.manualActionInProgress = true
    MACChangeService.randomizePrivate(interface: interface, state: state)

    XCTAssertEqual("A MAC change is already in progress.", state.manualActionError)
    XCTAssertNil(state.manualActionMessage)
    XCTAssertTrue(state.manualActionInProgress)
  }

  func testOriginalMACCachePreservesFirstBaselineAcrossReloads() {
    let state = LinkState()
    let originalMAC = MAC("aa:bb:cc:dd:ee:ff")!
    let staleSystemMAC = MAC("02:11:22:33:44:55")!

    let firstDiscovery = Interface(
      bsd: BSD("en0")!,
      hardMAC: originalMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: originalMAC
    )!

    let reloadedDiscovery = Interface(
      bsd: BSD("en0")!,
      hardMAC: staleSystemMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: originalMAC
    )!

    _ = state.preserveOriginalMACs(in: [firstDiscovery])
    let preservedReload = state.preserveOriginalMACs(in: [reloadedDiscovery])

    XCTAssertEqual(originalMAC, state.originalMACsByBSD["en0"])
    XCTAssertEqual(originalMAC, preservedReload.first?.hardMAC)
    XCTAssertEqual(originalMAC, preservedReload.first?.softMAC)
    XCTAssertTrue(preservedReload.first?.hasOriginalMAC ?? false)
  }

  func testRestoreUsesCachedOriginalAndPostRefreshMarksRowOriginal() {
    let state = LinkState()
    let originalMAC = MAC("aa:bb:cc:dd:ee:ff")!
    let spoofedMAC = MAC("02:11:22:33:44:55")!
    let bsd = BSD("en0")!
    let interface = Interface(
      bsd: bsd,
      hardMAC: spoofedMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: spoofedMAC
    )!

    state.originalMACsByBSD[bsd.name] = originalMAC
    state.allInterfaces = [interface]

    XCTAssertEqual(originalMAC, MACChangeService.originalMACTarget(interface: interface, state: state))
    XCTAssertFalse(interface.hasOriginalMAC)

    let restoredSnapshot = Interface(
      bsd: bsd,
      hardMAC: originalMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: originalMAC
    )!

    state.allInterfaces = state.preserveOriginalMACs(in: [restoredSnapshot])

    XCTAssertEqual(originalMAC, state.allInterfaces.first?.hardMAC)
    XCTAssertEqual(originalMAC, state.allInterfaces.first?.softMAC)
    XCTAssertTrue(state.allInterfaces.first?.hasOriginalMAC ?? false)
  }

  func testSpoofedCurrentMACReportsNotOriginal() {
    let interface = Interface(
      bsd: BSD("en0")!,
      hardMAC: MAC("84:2f:57:60:5c:89")!,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: MAC("02:62:09:64:2a:a6")!
    )!

    XCTAssertEqual(MAC("84:2f:57:60:5c:89"), interface.hardMAC)
    XCTAssertEqual(MAC("02:62:09:64:2a:a6"), interface.softMAC)
    XCTAssertFalse(interface.hasOriginalMAC)
  }

  func testInterfaceIdentityUsesBSDName() {
    let originalInterface = Interface(
      bsd: BSD("en0")!,
      hardMAC: MAC("84:2f:57:60:5c:89")!,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: MAC("02:62:09:64:2a:a6")!
    )!

    let restoredInterface = Interface(
      bsd: BSD("en0")!,
      hardMAC: MAC("84:2f:57:60:5c:89")!,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: MAC("84:2f:57:60:5c:89")!
    )!

    XCTAssertEqual("en0", originalInterface.id)
    XCTAssertEqual("en0", restoredInterface.id)
  }

  func testFreshSnapshotCanReplaceOldOriginalClassification() {
    let state = LinkState()
    let originalMAC = MAC("84:2f:57:60:5c:89")!
    let spoofedMAC = MAC("02:62:09:64:2a:a6")!

    let originalSnapshot = Interface(
      bsd: BSD("en0")!,
      hardMAC: originalMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: originalMAC
    )!

    state.allInterfaces = state.preserveOriginalMACs(in: [originalSnapshot])
    XCTAssertTrue(state.allInterfaces.first?.hasOriginalMAC ?? false)

    let spoofedSnapshot = Interface(
      bsd: BSD("en0")!,
      hardMAC: originalMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: spoofedMAC
    )!

    state.allInterfaces = state.preserveOriginalMACs(in: [spoofedSnapshot])

    XCTAssertEqual(originalMAC, state.allInterfaces.first?.hardMAC)
    XCTAssertEqual(spoofedMAC, state.allInterfaces.first?.softMAC)
    XCTAssertFalse(state.allInterfaces.first?.hasOriginalMAC ?? true)
  }

  func testFreshSnapshotCanReplaceStaleOriginalUIState() {
    let state = LinkState()
    let originalMAC = MAC("84:2f:57:60:5c:89")!
    let spoofedMAC = MAC("02:62:09:64:2a:a6")!

    let staleOriginalSnapshot = Interface(
      bsd: BSD("en0")!,
      hardMAC: originalMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: originalMAC
    )!

    state.allInterfaces = state.preserveOriginalMACs(in: [staleOriginalSnapshot])
    XCTAssertTrue(state.allInterfaces.first?.hasOriginalMAC ?? false)

    let freshSpoofedSnapshot = Interface(
      bsd: BSD("en0")!,
      hardMAC: originalMAC,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: spoofedMAC
    )!

    state.allInterfaces = state.preserveOriginalMACs(in: [freshSpoofedSnapshot])

    XCTAssertEqual(spoofedMAC, state.allInterfaces.first?.softMAC)
    XCTAssertFalse(state.allInterfaces.first?.hasOriginalMAC ?? true)
  }

  func testWiFiOffPreflightRefusesBeforeCommand() {
    let interface = Interface(
      bsd: BSD("en0")!,
      hardMAC: MAC("84:2f:57:60:5c:89")!,
      name: "Wi-Fi",
      kind: "IEEE80211",
      resolving: .none,
      stubSoftMAC: MAC("84:2f:57:60:5c:89")!
    )!

    XCTAssertThrowsError(try MACChangeService.validateWiFiPower(interface: interface, isPowerOn: false)) { error in
      XCTAssertEqual("Turn Wi-Fi on before changing en0's MAC address.", error.localizedDescription)
    }
  }

  func testWiFiPowerPreflightIgnoresEthernet() {
    let interface = Interface(
      bsd: BSD("en4")!,
      hardMAC: MAC("00:11:22:33:44:55")!,
      name: "Ethernet",
      kind: "Ethernet",
      resolving: .none,
      stubSoftMAC: MAC("00:11:22:33:44:55")!
    )!

    XCTAssertNoThrow(try MACChangeService.validateWiFiPower(interface: interface, isPowerOn: false))
  }

  func testNetworksetupHardwareAddressParserFindsPermanentMACsByBSD() {
    let output = """
    Hardware Port: Wi-Fi
    Device: en0
    Ethernet Address: aa:bb:cc:dd:ee:ff

    Hardware Port: Ethernet Adapter
    Device: en4
    Ethernet Address: 00:11:22:33:44:55
    """

    let addresses = Networksetup.Reader.parse(output)

    XCTAssertEqual(MAC("aa:bb:cc:dd:ee:ff"), addresses["en0"])
    XCTAssertEqual(MAC("00:11:22:33:44:55"), addresses["en4"])
  }
}
