// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

/// The main app preferences Window.
///
struct SettingsView: View {
  @Environment(LinkState.self) private var state

  /// We have static sidebar items and sidebar items views.
  /// Static is e.g. the "Welcome" and the "Troubleshoot" page.
  /// Dynamic is e.g. "Interface en1" and "Interface en2".
  /// Whatever is selected, we store as as String (not as `enum`).
  /// That gives us most flexibility.
  ///
  @State private var selectedFolder: String? = Pane.welcome.rawValue

  var body: some View {
    HStack(spacing: 0) {
      sidebar
        .frame(width: SettingsWindowMetrics.sidebarWidth)

      Divider()

      SettingsDetailView(selectedFolder: $selectedFolder).environment(state)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    .background(Color(nsColor: .windowBackgroundColor))
    .frame(minWidth: SettingsWindowMetrics.minimumSize.width,
           idealWidth: SettingsWindowMetrics.initialSize.width,
           minHeight: SettingsWindowMetrics.minimumSize.height,
           idealHeight: SettingsWindowMetrics.initialSize.height)
  }

  private var sidebar: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        SettingsSidebarSection("General") {
          SettingsSidebarRow("Welcome",
                             systemImage: "sparkles",
                             value: Pane.welcome.rawValue,
                             selection: $selectedFolder)
          SettingsSidebarRow("FAQ",
                             systemImage: "questionmark.bubble",
                             value: Pane.help.rawValue,
                             selection: $selectedFolder)
        }

        SettingsSidebarSection("Randomization") {
          SettingsSidebarRow("Vendors",
                             systemImage: "shippingbox",
                             value: Pane.vendors.rawValue,
                             selection: $selectedFolder)
        }

        if !state.allInterfaces.isEmpty {
          SettingsSidebarSection("Interfaces") {
            ForEach(state.allInterfaces) { interface in
              SettingsSidebarRow(interface.name,
                                 systemImage: interface.iconName,
                                 value: interface.id,
                                 selection: $selectedFolder)
            }
          }
        }

        SettingsSidebarSection("Advanced") {
          SettingsSidebarRow("Troubleshoot",
                             systemImage: "wrench.and.screwdriver",
                             value: Pane.troubleshoot.rawValue,
                             selection: $selectedFolder)
          SettingsSidebarRow("Uninstall",
                             systemImage: "trash",
                             value: Pane.uninstall.rawValue,
                             selection: $selectedFolder)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
  }
}

enum SettingsWindowMetrics {
  static let initialSize = CGSize(width: 860, height: 600)
  static let minimumSize = CGSize(width: 780, height: 520)
  static let sidebarWidth: CGFloat = 210
  static let autosaveName = "LinkLiarLocalSettings.v3"
}

extension SettingsView {
  enum Pane: String {
    case welcome
    case vendors
    case troubleshoot
    case help
    case uninstall
  }
}

private struct SettingsSidebarSection<Content: View>: View {
  let title: String
  @ViewBuilder let content: () -> Content

  init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)

      VStack(alignment: .leading, spacing: 2) {
        content()
      }
    }
  }
}

private struct SettingsSidebarRow: View {
  let title: String
  let systemImage: String
  let value: String
  @Binding var selection: String?

  init(_ title: String, systemImage: String, value: String, selection: Binding<String?>) {
    self.title = title
    self.systemImage = systemImage
    self.value = value
    self._selection = selection
  }

  private var isSelected: Bool { selection == value }

  var body: some View {
    Button {
      selection = value
    } label: {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 13, weight: .semibold))
          .frame(width: 18)
        Text(title)
          .font(.system(.subheadline, weight: isSelected ? .semibold : .regular))
          .lineLimit(1)
        Spacer(minLength: 0)
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 6)
      .foregroundStyle(isSelected ? Color.primary : Color.secondary)
      .background(
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.clear)
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}

#Preview {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)

  return SettingsView().environment(state)
}
