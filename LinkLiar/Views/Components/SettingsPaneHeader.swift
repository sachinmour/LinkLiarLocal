// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

/// Headline used at the top of each Settings detail pane.
/// Provides a consistent visual rhythm across the window.
///
struct SettingsPaneHeader: View {
  let title: String
  let subtitle: String?
  let systemImage: String
  let tint: Color

  init(_ title: String,
       subtitle: String? = nil,
       systemImage: String,
       tint: Color = .accentColor) {
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.tint = tint
  }

  var body: some View {
    HStack(alignment: .center, spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(tint.opacity(0.16))
        Image(systemName: systemImage)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(tint)
      }
      .frame(width: 44, height: 44)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.title2.weight(.semibold))
        if let subtitle {
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      Spacer(minLength: 0)
    }
  }
}

#Preview {
  VStack(spacing: 16) {
    SettingsPaneHeader(
      "Welcome",
      subtitle: "Learn how LinkLiar protects your MAC address.",
      systemImage: "sparkles"
    )
    SettingsPaneHeader(
      "Troubleshoot",
      subtitle: "Inspect logs, configuration, and version info.",
      systemImage: "wrench.and.screwdriver",
      tint: .orange
    )
  }
  .padding()
  .frame(width: 540)
}
