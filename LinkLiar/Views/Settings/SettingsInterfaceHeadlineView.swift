// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct SettingsInterfaceHeadlineView: View {
  @Environment(Interface.self) private var interface

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      HStack(alignment: .firstTextBaseline) {
        Image(systemName: interface.iconName).imageScale(.large)

        VStack(alignment: .leading) {
          HStack(alignment: .firstTextBaseline) {
            Text(interface.name)
              .font(.title2)
            Text(interface.bsd.name)
              .font(.system(.body, design: .monospaced))
              .opacity(0.5)
          }
          Text(interface.hardMAC.address)
            .font(.system(.body, design: .monospaced))
            .opacity(0.5)
        }
      }
      Spacer()
    }.padding(.bottom)
  }
}

#Preview("Hidden WiFi") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).first!

  return SettingsInterfaceHeadlineView().environment(state)
    .environment(interface)
}

#Preview("Hidden Cable") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).last!

  return SettingsInterfaceHeadlineView().environment(state)
    .environment(interface)
}
