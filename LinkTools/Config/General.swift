// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

extension Config {
  struct General {
    // MARK: Initialization

    init(dictionary: [String: Any]) {
      self.dictionary = dictionary
    }

    // MARK: Public Instance Properties

    var dictionary: [String: Any]

    /// Queries whether MAC addresses should be anonymized in GUI and logs.
    /// This is no by default. You can turn it on by adding the key.
    ///
    var isAnonymized: Bool {
      self.dictionary[Config.Key.anonymize.rawValue] as? Bool ?? false
    }
  }
}
