// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

enum Config {}

///
/// An immutable wrapper for querying the content of the configuration file.
///
extension Config {
  struct Reader {
    // MARK: Class Methods

    init(_ dictionary: [String: Any]) {
      self.dictionary = dictionary
    }

    // MARK: Public Instance Properties

    ///
    /// Gives (readonly) access to the underlying Dictionary of this configuration.
    /// This is basically the JSON content of the configuration file as Dictionary.
    ///
    var dictionary: [String: Any]

    ///
    /// Queries the version with which the configuration was created.
    ///
    lazy var version: String? = {
      dictionary[Config.Key.version.rawValue] as? String
    }()

    ///
    /// Queries universal LinkLiar settings.
    ///
    var general: General {
      General(dictionary: dictionary)
    }

    ///
    /// Queries the list of Vendors.
    ///
    var vendors: Vendors {
      Vendors(dictionary: dictionary)
    }

    ///
    /// Queries the list of Vendor MAC prefixes.
    ///
    var ouis: OUIs {
      OUIs(dictionary: dictionary)
    }
  }
}

extension Config {
  enum Key: String {
    case apple
    case anonymize
    case vendors
    case version
  }
}
