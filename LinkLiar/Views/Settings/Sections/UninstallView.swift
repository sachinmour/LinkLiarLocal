// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct UninstallView: View {
    @Environment(LinkState.self) private var state

    var body: some View {
      ScrollView {
        VStack(alignment: .center) {
          Image(systemName: "trash.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .padding(.bottom, 3)
          Text("Uninstall LinkLiar Local").bold()
        }.padding()

        VStack(alignment: .leading) {
          HStack {
            Text("There is no background service installed by LinkLiar Local.")
          }.padding(.bottom)
          HStack {
            Text("Delete")
            Text("LinkLiar Local.app").monospaced().bold()
            Text("to uninstall the app.")
          }.padding(.bottom)
        }

      }.padding()
    }
  }
}

#Preview {
  let state = LinkState()
  return SettingsView.UninstallView().environment(state)
}
