// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

/// Depending on which main setting category you chose in the sidebar,
/// this class determines the view for you to see in the right-side detail view.
///
struct SettingsDetailView: View {
  @Environment(LinkState.self) private var state

  @Binding var selectedFolder: String?

  var body: some View {
    Group {
      switch selectedFolder {
      case nil:
        emptyState

      case SettingsView.Pane.welcome.rawValue:
        SettingsView.WelcomeView().environment(state)

      case SettingsView.Pane.help.rawValue:
        SettingsView.FaqView().environment(state)

      case SettingsView.Pane.vendors.rawValue:
        SettingsView.VendorsView().environment(state)

      case SettingsView.Pane.troubleshoot.rawValue:
        SettingsView.TroubleshootView().environment(state)

      case SettingsView.Pane.uninstall.rawValue:
        SettingsView.UninstallView().environment(state)

      default:
        if let interface = state.allInterfaces.first(where: { $0.id == selectedFolder }) {
          SettingsView.InterfacePolicyView()
            .environment(state)
            .environment(interface)
        } else {
          // The Interface currently edited was unplugged.
          unpluggedInterfaceState
        }
      }
    }
    .id(selectedFolder ?? "none")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  private var emptyState: some View {
    VStack(spacing: 8) {
      Image(systemName: "sidebar.left")
        .symbolRenderingMode(.hierarchical)
        .font(.system(size: 36))
        .foregroundStyle(.tertiary)
      Text("Select a topic from the sidebar.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var unpluggedInterfaceState: some View {
    VStack(spacing: 8) {
      Image(systemName: "cable.connector")
        .symbolRenderingMode(.hierarchical)
        .font(.system(size: 36))
        .foregroundStyle(.tertiary)
      Text("That interface is no longer connected.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
