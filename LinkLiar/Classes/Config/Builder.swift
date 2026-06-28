// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

extension Config {
  struct Builder {
    init(_ dictionary: [String: Any]) {
      self.configDictionary = dictionary
    }

    func addVendor(_ vendor: Vendor) -> [String: Any] {
      var dictionary = configDictionary
      var currentVendorIds = dictionary[Config.Key.vendors.rawValue] as? [String] ?? []
      currentVendorIds.append(vendor.id)

      dictionary[Config.Key.vendors.rawValue] = Array(Set(currentVendorIds)).sorted()

      return dictionary
    }

    func removeVendor(_ vendor: Vendor) -> [String: Any] {
      var dictionary = configDictionary
      var currentVendorIds = dictionary[Config.Key.vendors.rawValue] as? [String] ?? []
      currentVendorIds.removeAll(where: { $0 == vendor.id })
      let newVendors = Array(Set(currentVendorIds)).sorted()

      if newVendors.isEmpty {
        dictionary.removeValue(forKey: Config.Key.vendors.rawValue)
      } else {
        dictionary[Config.Key.vendors.rawValue] = newVendors
      }

      return dictionary
    }

    func addAllVendors() -> [String: Any] {
      var dictionary = configDictionary
      dictionary[Config.Key.vendors.rawValue] = PopularVendorsDatabase.dictionaryWithCounts.keys.sorted()
      return dictionary
    }

    func removeAllVendors() -> [String: Any] {
      var dictionary = configDictionary
      dictionary.removeValue(forKey: Config.Key.vendors.rawValue)
      return dictionary
    }

    private var configDictionary: [String: Any]
  }
}
