// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct UninstallView: View {
    @Environment(LinkState.self) private var state

    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          SettingsPaneHeader(
            "Uninstall",
            subtitle: "How to remove LinkLiar Local from your Mac.",
            systemImage: "trash",
            tint: .red
          )

          InfoCard("Drag-and-drop removal",
                   subtitle: "There is no installer or background service to remove.",
                   systemImage: "hand.tap.fill",
                   accent: .accent) {
            VStack(alignment: .leading, spacing: 10) {
              StepRow(
                number: "1",
                title: "Quit LinkLiar",
                description: "Open the menu bar item and choose Quit (⌘Q)."
              )
              StepRow(
                number: "2",
                title: "Move LinkLiar Local.app to the Trash",
                description: "Drag the app from /Applications (or wherever you placed it) to the Trash, then empty it.",
                highlight: "LinkLiar Local.app"
              )
              StepRow(
                number: "3",
                title: "Optional — remove configuration & logs",
                description: "Open the Troubleshoot pane to copy the paths to the configuration and log files, then delete them from Finder."
              )
            }
          }

          InfoCard("What LinkLiar leaves behind",
                   subtitle: "By design, this fork installs no privileged components.",
                   systemImage: "lock.shield.fill",
                   accent: .success) {
            VStack(alignment: .leading, spacing: 8) {
              ItemRow(systemImage: "xmark.circle.fill",
                      tint: .red,
                      text: "No LaunchDaemon")
              ItemRow(systemImage: "xmark.circle.fill",
                      tint: .red,
                      text: "No background helper process")
              ItemRow(systemImage: "xmark.circle.fill",
                      tint: .red,
                      text: "No XPC service or Mach port")
              ItemRow(systemImage: "checkmark.circle.fill",
                      tint: .green,
                      text: "Only user-level files under ~/Library/")
            }
          }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

private struct StepRow: View {
  let number: String
  let title: String
  let description: String
  var highlight: String?

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Text(number)
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundStyle(.tint)
        .frame(width: 22, height: 22)
        .background(
          Circle().fill(Color.accentColor.opacity(0.16))
        )

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(.subheadline, weight: .semibold))
        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
        if let highlight {
          Text(highlight)
            .font(.system(.caption, design: .monospaced).weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
              RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.primary.opacity(0.07))
            )
            .padding(.top, 2)
        }
      }
      Spacer(minLength: 0)
    }
  }
}

private struct ItemRow: View {
  let systemImage: String
  let tint: Color
  let text: String

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: systemImage)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(tint)
        .font(.system(size: 12, weight: .semibold))
      Text(text)
        .font(.subheadline)
      Spacer(minLength: 0)
    }
  }
}

#Preview {
  let state = LinkState()
  return SettingsView.UninstallView().environment(state).frame(width: 560, height: 600)
}
