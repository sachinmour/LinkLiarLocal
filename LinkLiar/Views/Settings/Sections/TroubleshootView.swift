// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI
import AppKit

extension SettingsView {
  struct TroubleshootView: View {
    @Environment(LinkState.self) private var state

    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          SettingsPaneHeader(
            "Troubleshoot",
            subtitle: "Inspect version info and locate the on-disk configuration and log files.",
            systemImage: "wrench.and.screwdriver",
            tint: .orange
          )

          InfoCard("About",
                   systemImage: "info.circle.fill",
                   accent: .accent) {
            LabeledRow(
              icon: "app.badge",
              iconTint: .blue,
              label: "Application",
              value: "LinkLiar Local"
            )
            Divider().opacity(0.4)
            LabeledRow(
              icon: "number",
              iconTint: .indigo,
              label: "Version",
              value: state.version.formatted,
              isMonospaced: true
            )
          }

          InfoCard("Local Storage",
                   subtitle: "These files live in your user library and are private to your account.",
                   systemImage: "folder.fill",
                   accent: .accent) {
            PathRow(
              icon: "doc.text.fill",
              iconTint: .blue,
              label: "Configuration",
              path: Paths.configFile,
              url: Paths.configFileURL
            )
            Divider().opacity(0.4)
            PathRow(
              icon: "doc.plaintext.fill",
              iconTint: .purple,
              label: "Debug Log",
              path: Paths.debugLogFile,
              url: Paths.debugLogFileURL
            )
          }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

private struct LabeledRow: View {
  let icon: String
  let iconTint: Color
  let label: String
  let value: String
  var isMonospaced: Bool = false

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .fill(iconTint.opacity(0.15))
        Image(systemName: icon)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(iconTint)
      }
      .frame(width: 28, height: 28)

      Text(label)
        .font(.subheadline)

      Spacer(minLength: 12)

      Text(value)
        .font(isMonospaced ? .system(.body, design: .monospaced) : .body)
        .foregroundStyle(.secondary)
        .textSelection(.enabled)
    }
  }
}

private struct PathRow: View {
  let icon: String
  let iconTint: Color
  let label: String
  let path: String
  let url: URL

  @State private var copiedRecently = false

  var fileExists: Bool {
    FileManager.default.fileExists(atPath: path)
  }

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .fill(iconTint.opacity(0.15))
        Image(systemName: icon)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(iconTint)
      }
      .frame(width: 28, height: 28)

      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 6) {
          Text(label)
            .font(.subheadline.weight(.semibold))
          if !fileExists {
            StatusPill("Not yet created", style: .neutral)
          }
        }
        Text(displayPath)
          .font(.system(.caption, design: .monospaced))
          .foregroundStyle(.secondary)
          .lineLimit(1)
          .truncationMode(.middle)
          .textSelection(.enabled)
      }

      Spacer(minLength: 8)

      HStack(spacing: 6) {
        Button {
          copyPath()
        } label: {
          Image(systemName: copiedRecently ? "checkmark" : "doc.on.doc")
            .frame(width: 14, height: 14)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .help("Copy path to clipboard")

        Button {
          revealInFinder()
        } label: {
          Image(systemName: "folder")
            .frame(width: 14, height: 14)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .help("Show in Finder")
        .disabled(!fileExists && !FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path))
      }
    }
  }

  private var displayPath: String {
    let home = NSHomeDirectory()
    if path.hasPrefix(home) {
      return "~" + String(path.dropFirst(home.count))
    }
    return path
  }

  private func copyPath() {
    Pasteboard.copy(path)
    withAnimation(.easeInOut(duration: 0.15)) {
      copiedRecently = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      withAnimation(.easeInOut(duration: 0.2)) {
        copiedRecently = false
      }
    }
  }

  private func revealInFinder() {
    if fileExists {
      NSWorkspace.shared.activateFileViewerSelecting([url])
    } else {
      // Fall back to opening the containing directory if the file doesn't yet exist.
      let containing = url.deletingLastPathComponent()
      NSWorkspace.shared.open(containing)
    }
  }
}

#Preview {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)
  return SettingsView.TroubleshootView().environment(state).frame(width: 600, height: 500)
}
