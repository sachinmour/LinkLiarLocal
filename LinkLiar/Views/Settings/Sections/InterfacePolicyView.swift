// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct InterfacePolicyView: View {
    @Environment(LinkState.self) private var state
    @Environment(Interface.self) private var interface

    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          SettingsInterfaceHeadlineView()
            .environment(state)
            .environment(interface)

          InfoCard("Current Status",
                   subtitle: "Live values queried from this interface.",
                   systemImage: "antenna.radiowaves.left.and.right",
                   accent: .accent) {
            DiagnoseInterfaceView()
              .environment(state)
              .environment(interface)
          }

          if interface.isSpoofable {
            actionsHint
          } else {
            readOnlyHint
          }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }

    private var actionsHint: some View {
      InfoCard("Change This Interface",
               subtitle: "MAC actions live in the menu bar so they're a click away.",
               systemImage: "menubar.rectangle",
               accent: .accent) {
        VStack(alignment: .leading, spacing: 8) {
          ActionHintRow(systemImage: "shuffle",
                        tint: .blue,
                        title: "Randomize Private",
                        description: "Generate a locally-administered MAC address.")
          ActionHintRow(systemImage: "wand.and.stars",
                        tint: .purple,
                        title: "Randomize Vendor-like",
                        description: "Borrow a real vendor prefix from your enabled list.")
          ActionHintRow(systemImage: "arrow.uturn.backward",
                        tint: .indigo,
                        title: "Restore Original",
                        description: "Revert to the factory hardware MAC.")
          ActionHintRow(systemImage: "pencil",
                        tint: .teal,
                        title: "Set Specific MAC",
                        description: "Type an exact MAC address to apply.")

          Divider().opacity(0.5).padding(.vertical, 4)

          HStack(spacing: 8) {
            Image(systemName: "info.circle")
              .foregroundStyle(.secondary)
              .font(.caption)
            Text("Every change requires an administrator approval prompt.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
    }

    private var readOnlyHint: some View {
      InfoCard("Read-only Interface",
               subtitle: "This interface cannot be modified.",
               systemImage: "lock.fill",
               accent: .neutral) {
        Text("LinkLiar can only change the MAC address of Wi‑Fi and Ethernet adapters. Bluetooth, Thunderbolt-bridge, and iPhone tethering interfaces are intentionally excluded.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

private struct ActionHintRow: View {
  let systemImage: String
  let tint: Color
  let title: String
  let description: String

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .fill(tint.opacity(0.15))
        Image(systemName: systemImage)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(tint)
      }
      .frame(width: 26, height: 26)

      VStack(alignment: .leading, spacing: 1) {
        Text(title)
          .font(.system(.subheadline, weight: .semibold))
        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer(minLength: 0)
    }
  }
}

#Preview("Wi-Fi") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).first!
  return SettingsView.InterfacePolicyView()
    .environment(state)
    .environment(interface)
    .frame(width: 560, height: 600)
}

#Preview("Ethernet") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).last!
  return SettingsView.InterfacePolicyView()
    .environment(state)
    .environment(interface)
    .frame(width: 560, height: 600)
}
