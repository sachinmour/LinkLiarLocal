// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import XCTest
@testable import LinkLiar

class ConfigBuilderTests: XCTestCase {
  func testAddVendor() {
    let input = [
      "vendors":
        ["3com", "apple"]
    ]
    let vendor = Vendor(id: "acme", name: "")
    let output = Config.Builder(input).addVendor(vendor)

    let expected = ["vendors": ["3com", "acme", "apple"]]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }

  func testAddVendorDuplicates() {
    let input = [
      "vendors":
        ["3com", "apple"]
    ]
    let vendor = Vendor(id: "apple", name: "")
    let output = Config.Builder(input).addVendor(vendor)

    let expected = ["vendors": ["3com", "apple"]]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }

  func testRemoveVendor() {
    let input = [
      "vendors":
        ["3com", "apple"]
    ]
    let vendor = Vendor(id: "apple", name: "")
    let output = Config.Builder(input).removeVendor(vendor)

    let expected = ["vendors": ["3com"]]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }

  func testRemoveVendorDuplicates() {
    let input = [
      "vendors":
        ["3com", "apple", "apple"]
    ]
    let vendor = Vendor(id: "apple", name: "")
    let output = Config.Builder(input).removeVendor(vendor)

    let expected = ["vendors": ["3com"]]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }

  func testRemoveVendorLast() {
    let input = [
      "vendors":
        ["3com"]
    ]
    let vendor = Vendor(id: "3com", name: "")
    let output = Config.Builder(input).removeVendor(vendor)

    let expected: [String: Any] = [:]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }

  func testAddAllVendors() {
    let input = [
      "vendors":
        ["3com"]
    ]
    let output = Config.Builder(input).addAllVendors()

    let expected = ["vendors":
                      [
                        "3com",
                        "apple",
                        "aruba",
                        "asustek",
                        "azurewave",
                        "china",
                        "cisco",
                        "cocacola",
                        "dell",
                        "dlink",
                        "eero",
                        "ericsson",
                        "extreme",
                        "google",
                        "hangzhou",
                        "hewlett",
                        "hp",
                        "htc",
                        "huawei",
                        "ibm",
                        "intel",
                        "lg",
                        "microsoft",
                        "motorola",
                        "murata",
                        "netgear",
                        "new",
                        "nintendo",
                        "nokia",
                        "samsung",
                        "sichuan",
                        "silicon",
                        "sony",
                        "texas",
                        "tplink",
                        "vantiva",
                        "vivo",
                        "xiaomi",
                        "zte",
                        "zyxel"
                      ]
    ]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }

  func testRemoveAllVendors() {
    let input = [
      "vendors":
        ["3com"]
    ]
    let output = Config.Builder(input).removeAllVendors()

    let expected: [String: Any] = [:]
    XCTAssertEqual(expected as NSDictionary, output as NSDictionary)
  }
}
