// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct ConfirmQuittingView: View {
  @Environment(LinkState.self) private var state

  var body: some View {
    if state.wantsToQuit {
      VStack(alignment: .leading, spacing: 12) {
        HStack(alignment: .top, spacing: 12) {
          ZStack {
            Circle().fill(Color.orange.opacity(0.18))
            Image(systemName: "exclamationmark.triangle.fill")
              .symbolRenderingMode(.hierarchical)
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(.orange)
          }
          .frame(width: 32, height: 32)

          VStack(alignment: .leading, spacing: 3) {
            Text("Quit while a change is in progress?")
              .font(.system(.subheadline, weight: .semibold))
            Text("Stopping now may leave the interface partially updated.")
              .font(.caption)
              .foregroundStyle(.secondary)
              .fixedSize(horizontal: false, vertical: true)
          }
          Spacer(minLength: 0)
        }

        HStack(spacing: 8) {
          Button("Cancel") {
            Controller.wantsToStay(state)
          }
          .keyboardShortcut(.cancelAction)
          .buttonStyle(.bordered)

          Spacer()

          Button(role: .destructive, action: Controller.quitForReal) {
            Text("Quit Anyway")
          }
          .buttonStyle(.borderedProminent)
          .tint(.orange)
        }
      }
      .padding(12)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(Color.orange.opacity(0.08))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(Color.orange.opacity(0.25), lineWidth: 0.5)
      )
      .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
  }
}

#Preview {
  let state = LinkState()
  state.wantsToQuit = true
  return ConfirmQuittingView().environment(state)
    .frame(width: 316)
    .padding()
}
