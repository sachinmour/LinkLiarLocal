// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct DiagnoseInterfaceView: View {
  @Environment(Interface.self) private var interface

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Hardware MAC")
        Spacer()
        Text(interface.hardMAC.address)
          .font(.system(.body, design: .monospaced))
          .foregroundColor(.secondary)
      }

      HStack {
        Text("Current MAC")
        Spacer()
        Text(interface.softMAC?.address ?? "??:??:??:??:??:??")
          .font(.system(.body, design: .monospaced))
          .foregroundColor(.secondary)
      }
    }
  }
}
