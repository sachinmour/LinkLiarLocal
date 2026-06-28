// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct DiagnoseInterfaceView: View {
  @Environment(LinkState.self) private var state
  @Environment(Interface.self) private var interface

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      row(
        label: "Hardware MAC",
        icon: "cpu",
        iconTint: .indigo,
        address: interface.hardMAC.anonymous(state.config.general.isAnonymized),
        rawAddress: interface.hardMAC.address,
        accessory: nil
      )

      Divider().opacity(0.4)

      row(
        label: "Current MAC",
        icon: "antenna.radiowaves.left.and.right",
        iconTint: interface.hasOriginalMAC ? .orange : .green,
        address: interface.softMAC?.anonymous(state.config.general.isAnonymized) ?? "??:??:??:??:??:??",
        rawAddress: interface.softMAC?.address ?? "??:??:??:??:??:??",
        accessory: interface.hasOriginalMAC
          ? AnyView(StatusPill("Same as hardware",
                               systemImage: "exclamationmark.triangle.fill",
                               style: .warning))
          : AnyView(StatusPill("Modified",
                               systemImage: "checkmark.shield.fill",
                               style: .success))
      )

      if let vendor = vendorName {
        Divider().opacity(0.4)
        row(
          label: "Vendor",
          icon: "building.2",
          iconTint: .teal,
          address: vendor,
          rawAddress: vendor,
          accessory: nil,
          monospaced: false
        )
      }
    }
  }

  private var vendorName: String? {
    guard interface.softMAC != nil else { return nil }
    let name = MACVendors.name(interface.softOUI)
    return name == "No Vendor" ? nil : name
  }

  @ViewBuilder
  private func row(label: String,
                   icon: String,
                   iconTint: Color,
                   address: String,
                   rawAddress: String,
                   accessory: AnyView?,
                   monospaced: Bool = true) -> some View {
    HStack(alignment: .center, spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .fill(iconTint.opacity(0.15))
        Image(systemName: icon)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(iconTint)
      }
      .frame(width: 28, height: 28)

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.caption)
          .foregroundStyle(.secondary)
        if monospaced {
          CopyableMACText(address, size: .body)
        } else {
          Text(address)
            .font(.subheadline)
        }
      }

      Spacer(minLength: 0)

      if let accessory {
        accessory
      }
    }
  }
}
