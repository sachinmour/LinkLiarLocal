// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct SettingsInterfaceHeadlineView: View {
  @Environment(LinkState.self) private var state
  @Environment(Interface.self) private var interface

  var body: some View {
    HStack(alignment: .center, spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(iconTint.opacity(0.16))
        Image(systemName: interface.iconName)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(iconTint)
      }
      .frame(width: 44, height: 44)

      VStack(alignment: .leading, spacing: 3) {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(interface.name)
            .font(.title2.weight(.semibold))

          Text(interface.bsd.name)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
              RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.primary.opacity(0.07))
            )
        }
        Text(kindLabel)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)

      statusPill
    }
  }

  private var iconTint: Color {
    interface.kind == "IEEE80211" ? .blue : .indigo
  }

  private var kindLabel: String {
    switch interface.kind {
    case "IEEE80211": return "Wi‑Fi adapter"
    case "Ethernet":  return "Ethernet adapter"
    default:          return interface.kind
    }
  }

  @ViewBuilder
  private var statusPill: some View {
    if !interface.isSpoofable {
      StatusPill("Read-only", systemImage: "lock.fill", style: .neutral)
    } else if interface.hasOriginalMAC {
      StatusPill("Original MAC", systemImage: "exclamationmark.triangle.fill", style: .warning)
    } else {
      StatusPill("Spoofed", systemImage: "checkmark.shield.fill", style: .success)
    }
  }
}

#Preview("Wi-Fi") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).first!
  return SettingsInterfaceHeadlineView()
    .environment(state)
    .environment(interface)
    .padding()
    .frame(width: 560)
}

#Preview("Ethernet") {
  let state = LinkState()
  let interface = Interfaces.all(.sync).last!
  return SettingsInterfaceHeadlineView()
    .environment(state)
    .environment(interface)
    .padding()
    .frame(width: 560)
}
