// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct InterfacesView: View {
  @Environment(LinkState.self) private var state

  var body: some View {
    if state.allInterfaces.isEmpty {
      EmptyInterfacesView()
    } else {
      VStack(alignment: .leading, spacing: 2) {
        ForEach(state.allInterfaces) { interface in
          InterfaceView(state: state, interface: interface)
        }
      }
    }
  }
}

private struct EmptyInterfacesView: View {
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "antenna.radiowaves.left.and.right.slash")
        .symbolRenderingMode(.hierarchical)
        .font(.system(size: 28))
        .foregroundStyle(.secondary)
      Text("No network interfaces detected")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text("Connect a Wi-Fi or Ethernet adapter and try again.")
        .font(.caption)
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
  }
}

#Preview("InterfacesView") {
  let state = LinkState()
  Controller.queryInterfaces(state: state)
  return InterfacesView().environment(state)
    .frame(width: 340)
    .padding()
}
