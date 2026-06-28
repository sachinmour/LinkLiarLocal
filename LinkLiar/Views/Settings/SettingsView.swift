// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

/// The main app preferences Window.
///
struct SettingsView: View {
  @Environment(LinkState.self) private var state

  /// We have static sidebar items and sidebar items views.
  /// Static is e.g. the "Welcome" and the "Troubleshoot" page.
  /// Dynamic is e.g. "Interface en1" and "Interface en2"
  /// Whatever is selected, we store as as String (not as `enum`).
  /// That gives us most flexibility.
  ///
  @State private var selectedFolder: String? = Pane.welcome.rawValue

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedFolder) {
        Spacer()

        NavigationLink(value: Pane.welcome.rawValue) {
          Label("Welcome", systemImage: "figure.dance")
        }

        NavigationLink(value: Pane.help.rawValue) {
          Label("FAQ", systemImage: "book.pages")
        }

        Spacer()

        NavigationLink(value: Pane.vendors.rawValue) {
          Label("Vendors", systemImage: "apple.logo")
        }

        Spacer()
        Text("Interfaces")

        ForEach(state.allInterfaces) { interface in
          NavigationLink(value: interface.id) {
            Label(interface.name, systemImage: interface.iconName)
          }
        }

        Spacer()

        NavigationLink(value: Pane.troubleshoot.rawValue) {
          Label("Troubleshoot", systemImage: "bandage")
        }

        NavigationLink(value: Pane.uninstall.rawValue) {
          Label("Uninstall", systemImage: "trash")
        }

      }
      .toolbar(removing: .sidebarToggle)
      .navigationSplitViewColumnWidth(155)

    } detail: {
      SettingsDetailView(selectedFolder: $selectedFolder).environment(state)

    }.presentedWindowStyle(.hiddenTitleBar)
      .frame(minWidth: 780, idealWidth: 780, maxWidth: 780, minHeight: 500, idealHeight: 500, maxHeight: 800)
  }
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

#Preview {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)

  return SettingsView().environment(state)
}
