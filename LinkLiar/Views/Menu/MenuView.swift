// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct MenuView: View {
  @State var observer: NSKeyValueObservation?
  @Environment(LinkState.self) private var state

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      header

      if !state.allInterfaces.isEmpty {
        Divider().opacity(0.6)
      }

      InterfacesView().environment(state)

      if state.manualActionMessage != nil || state.manualActionError != nil {
        statusBanner
      }

      Divider().opacity(0.6)

      footer

      ConfirmQuittingView().environment(state)
    }
    .padding(12)
    .frame(width: 360)
    .fixedSize(horizontal: false, vertical: true)

    .onAppear {
      // See https://damian.fyi/swift/2022/12/29/detecting-when-a-swiftui-menubarextra-with-window-style-is-opened.html
      // For some reason this also triggers when the Settings view received or loosed focus.
      // I guess that's a good thing.
      observer = NSApplication.shared.observe(\.keyWindow) { _, _ in
        NotificationCenter.default.post(name: .menuBarAppeared, object: nil)
      }
    }
  }

  // MARK: - Header

  private var header: some View {
    HStack(alignment: .center, spacing: 10) {
      ZStack {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.tint.opacity(0.15))
        Image(systemName: "shield.lefthalf.filled")
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.tint)
      }
      .frame(width: 28, height: 28)

      VStack(alignment: .leading, spacing: 1) {
        Text("LinkLiar")
          .font(.system(.body, weight: .semibold))
        Text("MAC Address Privacy")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)

      overallStatusPill
    }
  }

  private var overallStatusPill: some View {
    Group {
      if state.allInterfaces.isEmpty {
        StatusPill("Idle", systemImage: "moon.zzz", style: .neutral)
      } else if state.warnAboutLeakage {
        StatusPill("Exposed", systemImage: "exclamationmark.triangle.fill", style: .warning)
      } else {
        StatusPill("Protected", systemImage: "checkmark.shield.fill", style: .success)
      }
    }
  }

  // MARK: - Status banner

  @ViewBuilder
  private var statusBanner: some View {
    if let error = state.manualActionError {
      banner(
        icon: "xmark.octagon.fill",
        iconColor: .red,
        title: "Action failed",
        detail: error,
        showsProgress: false
      )
    } else if let message = state.manualActionMessage {
      banner(
        icon: state.manualActionInProgress ? "lock.fill" : "checkmark.seal.fill",
        iconColor: state.manualActionInProgress ? .secondary : .green,
        title: state.manualActionInProgress ? "In Progress" : "Done",
        detail: message,
        showsProgress: state.manualActionInProgress
      )
    }
  }

  private func banner(icon: String,
                      iconColor: Color,
                      title: String,
                      detail: String,
                      showsProgress: Bool) -> some View {
    HStack(alignment: .top, spacing: 10) {
      ZStack {
        Circle().fill(iconColor.opacity(0.15))
        if showsProgress {
          ProgressView()
            .controlSize(.small)
            .scaleEffect(0.8)
        } else {
          Image(systemName: icon)
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(iconColor)
        }
      }
      .frame(width: 24, height: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(.subheadline, weight: .semibold))
          .foregroundStyle(iconColor)
        Text(detail)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(iconColor.opacity(0.08))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .stroke(iconColor.opacity(0.18), lineWidth: 0.5)
    )
  }

  // MARK: - Footer

  private var footer: some View {
    HStack(spacing: 8) {
      Button {
        SettingsWindowPresenter.show(state: state)
      } label: {
        Label("Settings", systemImage: "gearshape")
      }
      .keyboardShortcut(",", modifiers: .command)
      .buttonStyle(.accessoryBar)
      .help("Open settings (⌘,)")

      Spacer()

      Button {
        Controller.wantsToQuit(state)
      } label: {
        Label("Quit", systemImage: "power")
      }
      .keyboardShortcut("q")
      .buttonStyle(.accessoryBar)
      .help("Quit LinkLiar (⌘Q)")
    }
  }
}

#Preview("Standard") {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)
  return MenuView().environment(state)
}

#Preview("With action message") {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)
  state.manualActionMessage = "en0 changed to aa:bb:cc:••:••:••"
  return MenuView().environment(state)
}

#Preview("With error") {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)
  state.manualActionError = "Administrator authorization was cancelled."
  return MenuView().environment(state)
}

#Preview("In progress") {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)
  state.manualActionMessage = "Waiting for administrator approval…"
  state.manualActionInProgress = true
  return MenuView().environment(state)
}

#Preview("Wanting to quit") {
  let state = LinkState()
  state.allInterfaces = Interfaces.all(.sync)
  state.wantsToQuit = true
  state.manualActionInProgress = true
  state.manualActionMessage = "Waiting for administrator approval…"
  return MenuView().environment(state)
}

#Preview("No Interfaces") {
  let state = LinkState()
  state.allInterfaces = []
  return MenuView().environment(state)
}
