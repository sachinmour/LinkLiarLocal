// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

extension Config {
  struct Writer {
    init(_ state: LinkState) {
      self.state = state
    }

    func addVendor(_ vendor: Vendor) {
      persist(builder.addVendor(vendor))
    }

    func removeVendor(_ vendor: Vendor) {
      persist(builder.removeVendor(vendor))
    }

    func addAllVendors() {
      persist(builder.addAllVendors())
    }

    func removeAllVendors() {
      persist(builder.removeAllVendors())
    }

    private var state: LinkState

    private var builder: Config.Builder {
      Config.Builder(state.configDictionary)
    }

    private func persist(_ newDictionary: [String: Any]) {
      var mutableDictionary = newDictionary
      mutableDictionary[Config.Key.version.rawValue] = state.version.formatted

      if JSONWriter(Paths.configFile).write(mutableDictionary) {
        state.configDictionary = mutableDictionary
      }
    }
  }
}
