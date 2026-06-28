// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct InterfaceView: View {
  @Bindable var state: LinkState
  @Bindable var interface: Interface
  @State private var specificAddress = ""
  @State private var isSpecificMACPresented = false

  var body: some View {
    // Separating Icons and text
    HStack(spacing: 8) {
      if interface.hasOriginalMAC {
        Image("MenuIconLeaking")
      } else {
        // Invisible placeholder in the same size as the leaking icon.
        Image("MenuIconLeaking").opacity(0)
      }

      VStack(alignment: .leading) {
        HStack(spacing: 8) {
          Text(interface.name)
          Text(interface.bsd.name)
            .opacity(0.3)
            .font(.system(.body, design: .monospaced))
        }

        HStack(spacing: 8) {
          Button(action: {
            copy(interface.softMAC?.address ?? "??:??:??:??:??:??")
          }, label: {
            Text(interface.softMAC?.anonymous(state.config.general.isAnonymized) ?? "??:??:??:??:??:??")
              .font(.system(.body, design: .monospaced, weight: .light))
          }).buttonStyle(.plain)
        }

        Text(MACVendors.name(interface.softOUI))
          .font(.system(.footnote, design: .monospaced))
          .opacity(0.5)

        if !interface.hasOriginalMAC {
          HStack(spacing: 0) {
            Text("Originally ")
              .opacity(0.5)
              .font(.system(.footnote))
            Button(action: {
              copy(interface.hardMAC.address)
            }, label: {
              Text(interface.hardMAC.anonymous(state.config.general.isAnonymized))
                .font(.system(.footnote, design: .monospaced))
                .opacity(0.5)
            }).buttonStyle(.plain)
          }
        }
      }

      if interface.isSpoofable {
        Menu {
          actionItems
        } label: {
          Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .disabled(state.manualActionInProgress)
        .help("Interface actions")
      } else {
        // Padding parity on the right side (invisible).
        Image("MenuIconLeaking").opacity(0)
      }

    // Without this, only words (captions) are right-clickable. With it, you can click anywhere in this HStack.
    // See https://www.hackingwithswift.com/quick-start/swiftui/how-to-control-the-tappable-area-of-a-view-using-contentshape
    }.contentShape(Rectangle())
    .contextMenu {
      actionItems
    }.sheet(isPresented: $isSpecificMACPresented) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Set Specific MAC")
          .font(.headline)
        Text(interface.bsd.name)
          .font(.system(.body, design: .monospaced))
          .foregroundStyle(.secondary)
        TextField("aa:bb:cc:dd:ee:ff", text: $specificAddress)
          .textFieldStyle(.roundedBorder)
          .font(.system(.body, design: .monospaced))
        HStack {
          Spacer()
          Button("Cancel") {
            isSpecificMACPresented = false
          }
          Button("Apply") {
            MACChangeService.setSpecific(interface: interface, address: specificAddress, state: state)
            isSpecificMACPresented = false
          }
          .keyboardShortcut(.defaultAction)
          .disabled(state.manualActionInProgress)
        }
      }.padding()
        .frame(width: 280)
    }
  }

  private func copy(_ content: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
    pasteboard.setString(content, forType: NSPasteboard.PasteboardType.string)
  }

  @ViewBuilder
  private var actionItems: some View {
    Button("Copy MAC address") {
      copy(interface.softMAC?.address ?? "??:??:??:??:??:??")
    }

    if interface.isSpoofable {
      Divider()
      Button("Randomize Private") {
        MACChangeService.randomizePrivate(interface: interface, state: state)
      }
      .disabled(state.manualActionInProgress)

      Button("Randomize Vendor-like") {
        MACChangeService.randomizeVendorLike(interface: interface, state: state)
      }
      .disabled(state.manualActionInProgress)

      Button("Restore Original") {
        MACChangeService.restoreOriginal(interface: interface, state: state)
      }
      .disabled(state.manualActionInProgress)

      Button("Set Specific MAC") {
        specificAddress = interface.softMAC?.address ?? ""
        isSpecificMACPresented = true
      }
      .disabled(state.manualActionInProgress)
    }
  }
}

#Preview {
  let state = LinkState()
  let interfaces = Interfaces.all(.sync)
  return InterfaceView(state: state, interface: interfaces.first!)
}
