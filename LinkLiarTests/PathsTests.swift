// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import XCTest
@testable import LinkLiar

class PathsTests: XCTestCase {
  func testConfigDirectoryDefault() {
    XCTAssertEqual(
      "\(FileManager.default.homeDirectoryForCurrentUser.path)/Library/Application Support/LinkLiarLocal/config.json",
      Paths.configFile
    )
  }

  func testLogFileDefault() {
    XCTAssertEqual(
      "\(FileManager.default.homeDirectoryForCurrentUser.path)/Library/Logs/LinkLiarLocal/linkliar.log",
      Paths.debugLogFile
    )
  }

  func testRuntimePathsStayInUserLibrary() {
    XCTAssertTrue(Paths.configFile.hasPrefix(FileManager.default.homeDirectoryForCurrentUser.path))
    XCTAssertTrue(Paths.configFile.contains("/Library/Application Support/LinkLiarLocal/"))
    XCTAssertTrue(Paths.debugLogFile.hasPrefix(FileManager.default.homeDirectoryForCurrentUser.path))
    XCTAssertTrue(Paths.debugLogFile.contains("/Library/Logs/LinkLiarLocal/"))
    XCTAssertFalse(Paths.configFile.hasPrefix("/tmp/"))
    XCTAssertFalse(Paths.debugLogFile.hasPrefix("/tmp/"))
  }
}
