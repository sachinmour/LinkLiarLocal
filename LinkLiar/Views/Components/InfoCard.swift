// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

/// A card container that follows the visual language of macOS Settings panes.
/// Renders a subtle background with an optional titled header.
///
struct InfoCard<Content: View>: View {
  enum Accent {
    case neutral
    case accent
    case success
    case warning
    case danger

    var color: Color {
      switch self {
      case .neutral: return .secondary
      case .accent:  return .accentColor
      case .success: return .green
      case .warning: return .orange
      case .danger:  return .red
      }
    }
  }

  let title: String?
  let subtitle: String?
  let systemImage: String?
  let accent: Accent
  @ViewBuilder let content: () -> Content

  init(_ title: String? = nil,
       subtitle: String? = nil,
       systemImage: String? = nil,
       accent: Accent = .neutral,
       @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.accent = accent
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      if title != nil || systemImage != nil {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          if let systemImage {
            Image(systemName: systemImage)
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(accent.color)
              .font(.system(size: 14, weight: .semibold))
              .frame(width: 18)
          }
          VStack(alignment: .leading, spacing: 2) {
            if let title {
              Text(title)
                .font(.system(.subheadline, weight: .semibold))
            }
            if let subtitle {
              Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
          }
          Spacer(minLength: 0)
        }
      }

      content()
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
    )
  }
}

#Preview {
  ScrollView {
    VStack(spacing: 12) {
      InfoCard("Plain card") {
        Text("Some content.")
      }

      InfoCard("With icon",
               subtitle: "And a helpful subtitle.",
               systemImage: "wifi",
               accent: .accent) {
        Text("Content goes here.")
      }

      InfoCard("Warning",
               subtitle: "Pay attention.",
               systemImage: "exclamationmark.triangle.fill",
               accent: .warning) {
        Text("Be careful with this option.")
      }
    }
    .padding()
  }
  .frame(width: 480)
}
