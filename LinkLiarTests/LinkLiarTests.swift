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
}
