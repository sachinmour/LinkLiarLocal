// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI
import AppKit

/// A monospaced MAC address with an inline copy affordance.
/// The button gains visibility on hover and exposes a tooltip.
///
struct CopyableMACText: View {
  enum Size {
    case body
    case callout
    case footnote
    case headline

    var font: Font {
      switch self {
      case .body:     return .system(.body, design: .monospaced, weight: .regular)
      case .callout:  return .system(.callout, design: .monospaced, weight: .regular)
      case .footnote: return .system(.footnote, design: .monospaced, weight: .regular)
      case .headline: return .system(.title3, design: .monospaced, weight: .medium)
      }
    }
  }


  let address: String
  let size: Size
  let foregroundStyle: AnyShapeStyle

  @State private var isHovering = false
  @State private var copiedRecently = false

  init(_ address: String,
       size: Size = .body,
       foregroundStyle: AnyShapeStyle = AnyShapeStyle(HierarchicalShapeStyle.primary)) {
    self.address = address
    self.size = size
    self.foregroundStyle = foregroundStyle
  }

  var body: some View {
    HStack(spacing: 6) {
      Text(address)
        .font(size.font)
        .foregroundStyle(foregroundStyle)
        .textSelection(.enabled)

      Button(action: copy) {
        Image(systemName: copiedRecently ? "checkmark" : "doc.on.doc")
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(copiedRecently ? Color.green : Color.secondary)
          .frame(width: 14, height: 14)
      }
      .buttonStyle(.plain)
      .opacity(isHovering || copiedRecently ? 1 : 0.0)
      .help("Copy MAC address")
      .accessibilityLabel("Copy MAC address")
    }
    .contentShape(Rectangle())
    .onHover { hovering in
      isHovering = hovering
    }
  }

  private func copy() {
    Pasteboard.copy(address)
    withAnimation(.easeInOut(duration: 0.15)) {
      copiedRecently = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      withAnimation(.easeInOut(duration: 0.2)) {
        copiedRecently = false
      }
    }
  }
}

/// Small AppKit clipboard helper used across the UI to avoid duplication.
enum Pasteboard {
  static func copy(_ string: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(string, forType: .string)
  }
}

#Preview {
  VStack(alignment: .leading, spacing: 12) {
    CopyableMACText("aa:bb:cc:dd:ee:ff")
    CopyableMACText("aa:bb:cc:dd:ee:ff", size: .footnote,
                    foregroundStyle: AnyShapeStyle(HierarchicalShapeStyle.secondary))
    CopyableMACText("aa:bb:cc:dd:ee:ff", size: .headline)
  }
  .padding()
}
