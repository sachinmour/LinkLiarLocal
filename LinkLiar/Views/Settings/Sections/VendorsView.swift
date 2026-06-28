// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct VendorsView: View {
    @Environment(LinkState.self) private var state

    private var vendors: [Vendor] { state.config.vendors.popular }

    private var totalVendors: Int { vendors.count }
    private var chosenVendors: Int {
      vendors.filter { state.config.vendors.isChosen($0) }.count
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 14) {
        SettingsPaneHeader(
          "Vendor Prefixes",
          subtitle: "Choose which manufacturer prefixes are used when generating a vendor-like random MAC address.",
          systemImage: "shippingbox",
          tint: .orange
        )

        summary

        vendorList
          .layoutPriority(1)
      }
      .padding(24)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Summary

    private var summary: some View {
      HStack(spacing: 10) {
        Image(systemName: "checkmark.circle.fill")
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(.green)
        Text("\(chosenVendors) of \(totalVendors) vendors enabled")
          .font(.subheadline)
          .foregroundStyle(.primary)

        Spacer()

        Text("⌥-click toggles all")
          .font(.caption)
          .foregroundStyle(.secondary)
          .padding(.horizontal, 8)
          .padding(.vertical, 3)
          .background(
            Capsule().fill(Color.primary.opacity(0.06))
          )
      }
    }

    // MARK: - Vendor list

    private var vendorList: some View {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 2) {
          ForEach(Array(vendors.enumerated()), id: \.element.id) { index, vendor in
            VendorRow(
              vendor: vendor,
              isChosen: state.config.vendors.isChosen(vendor),
              zebraTint: index.isMultiple(of: 2)
            ) { newValue in
              toggleVendor(value: newValue, vendor: vendor)
            }
          }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .topLeading)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(Color(nsColor: .controlBackgroundColor).opacity(0.55))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
      )
    }

    // MARK: - Helpers

    private func toggleVendor(value: Bool, vendor: Vendor) {
      if CGKeyCode.optionKeyPressed {
        if value {
          Config.Writer(state).addAllVendors()
        } else {
          Config.Writer(state).removeAllVendors()
        }
        return
      }

      if value {
        Config.Writer(state).addVendor(vendor)
      } else {
        Config.Writer(state).removeVendor(vendor)
      }
    }
  }
}

// MARK: - Row

private struct VendorRow: View {
  let vendor: Vendor
  let isChosen: Bool
  let zebraTint: Bool
  let onToggle: (Bool) -> Void

  @State private var isHovering = false

  var body: some View {
    Button {
      onToggle(!isChosen)
    } label: {
      HStack(spacing: 12) {
        Image(systemName: isChosen ? "checkmark.square.fill" : "square")
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(isChosen ? Color.accentColor : Color.secondary)
          .font(.system(size: 13, weight: .semibold))
          .frame(width: 16)

        Image(systemName: "building.2.fill")
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(.secondary)
          .font(.system(size: 12))
          .frame(width: 16)

        Text(vendor.name)
          .font(.subheadline)
          .foregroundStyle(.primary)
          .lineLimit(1)

        Spacer(minLength: 8)

        HStack(spacing: 4) {
          Image(systemName: "number")
            .font(.caption2)
            .foregroundStyle(.tertiary)
          Text("\(vendor.prefixCount)")
            .font(.system(.subheadline, design: .monospaced))
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .fill(rowBackground)
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .onHover { hovering in
      isHovering = hovering
    }
    .accessibilityLabel(vendor.name)
    .accessibilityValue(isChosen ? "Enabled" : "Disabled")
  }

  private var rowBackground: Color {
    if isHovering {
      return Color.primary.opacity(0.06)
    }
    return zebraTint ? Color.primary.opacity(0.02) : Color.clear
  }
}

#Preview {
  let state = LinkState()
  return SettingsView.VendorsView().environment(state).frame(width: 600, height: 500)
}
