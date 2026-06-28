// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct InterfaceView: View {
  @Bindable var state: LinkState
  @Bindable var interface: Interface

  @State private var specificAddress = ""
  @State private var isSpecificMACPresented = false
  @State private var isRowHovering = false

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      iconBadge

      VStack(alignment: .leading, spacing: 4) {
        headerRow
        currentMACRow
        vendorRow
        if !interface.hasOriginalMAC {
          originalMACRow
        }
      }

      Spacer(minLength: 0)

      trailingControl
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 10)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(isRowHovering
              ? Color.primary.opacity(0.05)
              : Color.clear)
    )
    .contentShape(Rectangle())
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.12)) {
        isRowHovering = hovering
      }
    }
    .contextMenu { actionItems }
    .sheet(isPresented: $isSpecificMACPresented) {
      SpecificMACSheet(
        interface: interface,
        address: $specificAddress,
        isPresented: $isSpecificMACPresented,
        isDisabled: state.manualActionInProgress
      ) { trimmed in
        MACChangeService.setSpecific(interface: interface, address: trimmed, state: state)
      }
    }
  }

  // MARK: - Subviews

  private var iconBadge: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(iconTint.opacity(0.15))
      Image(systemName: interface.iconName)
        .symbolRenderingMode(.hierarchical)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(iconTint)
    }
    .frame(width: 32, height: 32)
  }

  private var headerRow: some View {
    HStack(alignment: .firstTextBaseline, spacing: 6) {
      Text(interface.name)
        .font(.system(.body, weight: .semibold))
        .lineLimit(1)
        .truncationMode(.tail)

      Text(interface.bsd.name)
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 5)
        .padding(.vertical, 1)
        .background(
          RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color.primary.opacity(0.06))
        )
        .layoutPriority(1)

      Spacer(minLength: 4)

      statusPill
        .layoutPriority(2)
    }
  }


  @ViewBuilder
  private var statusPill: some View {
    if !interface.isSpoofable {
      StatusPill("Read-only", systemImage: "lock.fill", style: .neutral)
    } else if interface.hasOriginalMAC {
      StatusPill("Original", systemImage: "exclamationmark.triangle.fill", style: .warning)
    } else {
      StatusPill("Spoofed", systemImage: "checkmark.shield.fill", style: .success)
    }
  }

  private var currentMACRow: some View {
    CopyableMACText(
      interface.softMAC?.anonymous(state.config.general.isAnonymized) ?? "??:??:??:??:??:??",
      size: .callout,
      foregroundStyle: AnyShapeStyle(HierarchicalShapeStyle.primary)
    )
  }

  @ViewBuilder
  private var vendorRow: some View {
    if interface.softMAC != nil {
      let vendor = MACVendors.name(interface.softOUI)
      Text(vendor)
        .font(.footnote)
        .foregroundStyle(.tertiary)
        .lineLimit(1)
    }
  }


  private var originalMACRow: some View {
    HStack(spacing: 4) {
      Image(systemName: "arrow.uturn.backward.circle")
        .font(.system(size: 10))
        .foregroundStyle(.tertiary)
      Text("Originally")
        .font(.footnote)
        .foregroundStyle(.tertiary)
      CopyableMACText(
        interface.hardMAC.anonymous(state.config.general.isAnonymized),
        size: .footnote,
        foregroundStyle: AnyShapeStyle(HierarchicalShapeStyle.tertiary)
      )
    }
  }

  @ViewBuilder
  private var trailingControl: some View {
    if interface.isSpoofable {
      Menu {
        actionItems
      } label: {
        Image(systemName: "ellipsis.circle")
          .font(.system(size: 18, weight: .regular))
          .foregroundStyle(.primary.opacity(0.6))
      }
      .menuStyle(.borderlessButton)
      .menuIndicator(.hidden)
      .fixedSize()
      .frame(width: 24, height: 24)
      .disabled(state.manualActionInProgress)
      .help("Interface actions")
    } else {
      Color.clear.frame(width: 24, height: 24)
    }
  }


  // MARK: - Action items

  @ViewBuilder
  private var actionItems: some View {
    Button {
      Pasteboard.copy(interface.softMAC?.address ?? "??:??:??:??:??:??")
    } label: {
      Label("Copy MAC Address", systemImage: "doc.on.doc")
    }

    if interface.isSpoofable {
      Divider()

      Button {
        MACChangeService.randomizePrivate(interface: interface, state: state)
      } label: {
        Label("Randomize Private", systemImage: "shuffle")
      }
      .disabled(state.manualActionInProgress)

      Button {
        MACChangeService.randomizeVendorLike(interface: interface, state: state)
      } label: {
        Label("Randomize Vendor-like", systemImage: "wand.and.stars")
      }
      .disabled(state.manualActionInProgress)

      Button {
        MACChangeService.restoreOriginal(interface: interface, state: state)
      } label: {
        Label("Restore Original", systemImage: "arrow.uturn.backward")
      }
      .disabled(state.manualActionInProgress)

      Divider()

      Button {
        specificAddress = interface.softMAC?.address ?? ""
        isSpecificMACPresented = true
      } label: {
        Label("Set Specific MAC…", systemImage: "pencil")
      }
      .disabled(state.manualActionInProgress)
    }
  }

  // MARK: - Helpers

  private var iconTint: Color {
    interface.kind == "IEEE80211" ? .blue : .indigo
  }
}

// MARK: - Set Specific MAC sheet

private struct SpecificMACSheet: View {
  let interface: Interface
  @Binding var address: String
  @Binding var isPresented: Bool
  let isDisabled: Bool
  let onApply: (String) -> Void

  @FocusState private var fieldFocused: Bool

  private var trimmedAddress: String {
    address.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var isValid: Bool {
    MAC(trimmedAddress) != nil
  }

  private var showsValidationHint: Bool {
    !trimmedAddress.isEmpty && !isValid
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "pencil.circle.fill")
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 28))
          .foregroundStyle(.tint)
        VStack(alignment: .leading, spacing: 2) {
          Text("Set Specific MAC")
            .font(.headline)
          Text("Apply a custom hardware address to \(interface.bsd.name).")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Spacer(minLength: 0)
      }

      VStack(alignment: .leading, spacing: 6) {
        Text("MAC Address")
          .font(.caption)
          .foregroundStyle(.secondary)

        TextField("aa:bb:cc:dd:ee:ff", text: $address)
          .textFieldStyle(.roundedBorder)
          .font(.system(.body, design: .monospaced))
          .focused($fieldFocused)
          .onSubmit(apply)
          .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
              .stroke(showsValidationHint ? Color.red.opacity(0.6) : Color.clear, lineWidth: 1)
          )

        HStack(spacing: 6) {
          if showsValidationHint {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundStyle(.red)
              .font(.caption)
            Text("Enter a valid MAC address (6 hex groups).")
              .font(.caption)
              .foregroundStyle(.secondary)
          } else {
            Image(systemName: "info.circle")
              .foregroundStyle(.secondary)
              .font(.caption)
            Text("You'll be asked to approve as an administrator.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
        }
      }

      Divider()

      HStack {
        Spacer()
        Button("Cancel", role: .cancel) {
          isPresented = false
        }
        .keyboardShortcut(.cancelAction)

        Button("Apply", action: apply)
          .keyboardShortcut(.defaultAction)
          .buttonStyle(.borderedProminent)
          .disabled(!isValid || isDisabled)
      }
    }
    .padding(20)
    .frame(width: 360)
    .onAppear { fieldFocused = true }
  }

  private func apply() {
    guard isValid else { return }
    onApply(trimmedAddress)
    isPresented = false
  }
}

#Preview {
  let state = LinkState()
  let interfaces = Interfaces.all(.sync)
  return InterfaceView(state: state, interface: interfaces.first!)
    .frame(width: 340)
    .padding()
}
