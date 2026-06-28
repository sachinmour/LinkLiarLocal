// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import XCTest
@testable import LinkLiar

class MACTest: XCTestCase {
  func testAbbreviations() {
    let mac = MAC("0a:b:60:84::e6")!
    XCTAssertEqual("0a:0b:60:84:00:e6", mac.address)
  }

  func testInvalidSuperfluousCharacters() {
    let mac = MAC(" X aa:bb/cc!:dd,ee:ff\n")!
    XCTAssertEqual("aa:bb:cc:dd:ee:ff", mac.address)
  }

  func testInvalid() {
    let mac = MAC("aa:bb:cc:dd:ee:fg")
    XCTAssertNil(mac)
  }

  func testPrivateRandomMacIsLocalAdminUnicast() throws {
    for _ in 0 ..< 25 {
      let mac = try RandomMACGenerator.privateLocalAdmin()
      let firstByte = UInt8(mac.address.split(separator: ":").first!, radix: 16)!

      XCTAssertEqual(0x02, firstByte & 0x02)
      XCTAssertEqual(0x00, firstByte & 0x01)
      XCTAssertNotNil(LinkLiar.MAC(mac.address))
    }
  }

  func testVendorLikeMacUsesFallbackPopularOUI() throws {
    let mac = try RandomMACGenerator.vendorLike(config: LinkLiar.Config.Reader([:]))
    let prefixes = Set(RandomMACGenerator.fallbackPopularOUIs.map(\.address))

    XCTAssertTrue(prefixes.contains(mac.prefix))
    XCTAssertNotNil(LinkLiar.MAC(mac.address))
  }

  func testIfconfigCommandBuilderAcceptsOnlyApprovedShape() throws {
    let mac = LinkLiar.MAC("02:11:22:33:44:55")!
    let command = try AdminCommandRunner.approvedIfconfigEtherCommandDescription(bsdName: "en0", mac: mac)

    XCTAssertEqual("/sbin/ifconfig", command.path)
    XCTAssertEqual(["en0", "ether", "02:11:22:33:44:55"], command.arguments)
    XCTAssertThrowsError(try AdminCommandRunner.approvedIfconfigEtherCommandDescription(bsdName: "en0;id", mac: mac))
    XCTAssertThrowsError(try AdminCommandRunner.approvedIfconfigEtherCommandDescription(bsdName: "awdl0", mac: mac))
  }
}
