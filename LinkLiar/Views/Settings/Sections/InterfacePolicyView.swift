// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct InterfacePolicyView: View {
    @Environment(LinkState.self) private var state
    @Environment(Interface.self) private var interface

    var body: some View {
      VStack {
        SettingsInterfaceHeadlineView().environment(state).environment(interface)

        DiagnoseInterfaceView().environment(state).environment(interface)

        Spacer()
      }.padding()
    }
  }
}

#Preview("Hidden") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).first!

  return SettingsView.InterfacePolicyView().environment(state).environment(interface)
}

#Preview("Ignored WiFi") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).first!

  return SettingsView.InterfacePolicyView().environment(state).environment(interface)
}

#Preview("Ignored Cable") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).last!

  return SettingsView.InterfacePolicyView().environment(state).environment(interface)
}

#Preview("Default WiFi") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).first!

  return SettingsView.InterfacePolicyView().environment(state).environment(interface)
}
