// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct TroubleshootView: View {
    @Environment(LinkState.self) private var state

    var body: some View {
      VStack(alignment: .leading) {
        Text("General").font(.headline)

        GroupBox {
          HStack(alignment: .top) {
            Text("GUI Version")
            Spacer()
            Text(state.version.formatted)
          }.padding(4)
        }

        Text("Local storage").font(.headline).padding(.top)

        GroupBox {
          HStack {
            Text("Config")
            Spacer()

            Text(Paths.configFile)
              .font(.system(.subheadline, design: .monospaced))
              .foregroundColor(.secondary)
          }.padding(4)
        }

        GroupBox {
          HStack {
            Text("Log")
            Spacer()
            Text(Paths.debugLogFile)
              .font(.system(.subheadline, design: .monospaced))
              .foregroundColor(.secondary)
          }.padding(4)
        }

        Spacer()
      }.padding()
    }
  }
}

#Preview {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)

  return SettingsView.TroubleshootView().environment(state)
}
