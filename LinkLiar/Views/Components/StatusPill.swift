// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

/// A small capsule badge used to communicate a status at a glance.
/// Designed to match the look and feel of native macOS controls.
///
struct StatusPill: View {
  enum Style {
    case success
    case warning
    case neutral
    case danger

    var tint: Color {
      switch self {
      case .success: return .green
      case .warning: return .orange
      case .neutral: return .secondary
      case .danger:  return .red
      }
    }
  }

  let title: String
  let systemImage: String?
  let style: Style

  init(_ title: String, systemImage: String? = nil, style: Style = .neutral) {
    self.title = title
    self.systemImage = systemImage
    self.style = style
  }

  var body: some View {
    HStack(spacing: 4) {
      if let systemImage {
        Image(systemName: systemImage)
          .font(.system(size: 9, weight: .semibold))
      }
      Text(title)
        .font(.system(size: 10, weight: .semibold))
        .textCase(.uppercase)
        .tracking(0.4)
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
    }
    .padding(.horizontal, 7)
    .padding(.vertical, 3)
    .foregroundStyle(style.tint)
    .background(
      Capsule(style: .continuous)
        .fill(style.tint.opacity(0.12))
    )
    .overlay(
      Capsule(style: .continuous)
        .stroke(style.tint.opacity(0.25), lineWidth: 0.5)
    )
    .fixedSize(horizontal: true, vertical: false)
  }

}

#Preview {
  VStack(alignment: .leading, spacing: 8) {
    StatusPill("Protected", systemImage: "checkmark.shield.fill", style: .success)
    StatusPill("Original MAC", systemImage: "exclamationmark.triangle.fill", style: .warning)
    StatusPill("Not Spoofable", systemImage: "lock.fill", style: .neutral)
    StatusPill("Error", systemImage: "xmark.octagon.fill", style: .danger)
  }
  .padding()
}
