// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct FaqView: View {
    @Environment(LinkState.self) private var state

    private static let entries: [FaqEntry] = [
      FaqEntry(
        icon: "eye.slash.fill",
        tint: .blue,
        title: "LinkLiar does not provide anonymity",
        body: "Even with a modified MAC address, the negotiation packets between your network interface and an access point can reveal what operating system you use. Network traffic may also be inspected to de-anonymize you."
      ),
      FaqEntry(
        icon: "drop.fill",
        tint: .cyan,
        title: "LinkLiar does not prevent MAC address leaks",
        body: "Your original hardware MAC address will be revealed when you cold boot your computer and Wi‑Fi is turned on. MAC address modifications do, however, persist when sleeping and waking your computer."
      ),
      FaqEntry(
        icon: "wifi.exclamationmark",
        tint: .orange,
        title: "Changing your MAC drops the active connection",
        body: "The MAC address of an interface cannot be modified while connected to a Wi‑Fi network. LinkLiar disassociates from any connected network before attempting to modify the MAC address."
      ),
      FaqEntry(
        icon: "power",
        tint: .green,
        title: "Wi‑Fi needs to be on for MAC modification",
        body: "When your Wi‑Fi is turned off, macOS will refuse to change its MAC address. Turn the radio on first, then trigger the change from the menu bar."
      )
    ]

    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          SettingsPaneHeader(
            "Frequently Asked Questions",
            subtitle: "Limitations and behaviors that are good to know about.",
            systemImage: "questionmark.bubble",
            tint: .purple
          )

          VStack(spacing: 12) {
            ForEach(Self.entries) { entry in
              FaqRow(entry: entry)
            }
          }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

private struct FaqEntry: Identifiable {
  let id = UUID()
  let icon: String
  let tint: Color
  let title: String
  let body: String
}

private struct FaqRow: View {
  let entry: FaqEntry

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(entry.tint.opacity(0.15))
        Image(systemName: entry.icon)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(entry.tint)
      }
      .frame(width: 38, height: 38)

      VStack(alignment: .leading, spacing: 4) {
        Text(entry.title)
          .font(.system(.subheadline, weight: .semibold))
        Text(entry.body)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer(minLength: 0)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.55))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .stroke(Color.primary.opacity(0.07), lineWidth: 0.5)
    )
  }
}

#Preview {
  let state = LinkState()
  return SettingsView.FaqView().environment(state).frame(width: 560, height: 600)
}
