// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

extension SettingsView {
  struct WelcomeView: View {
    @Environment(LinkState.self) private var state

    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          hero

          SettingsPaneHeader(
            "Why MAC Addresses Matter",
            subtitle: "A quick primer on what your computer reveals over the air.",
            systemImage: "sparkles"
          )

          chapter(
            number: "1",
            title: "Devices need addresses to talk to each other",
            body: "Mobile phones use phone numbers, and computers use IP addresses. Without one, two devices on the same network can’t tell each other apart."
          ) {
            ConversationCard(
              speakers: [
                .init(systemImage: "candybarphone", line: "Hello 55522? This is 55511."),
                .init(systemImage: "candybarphone", line: "Hi there!")
              ]
            )
          }

          chapter(
            number: "2",
            title: "Your router hands out IP addresses",
            body: "When a laptop joins a Wi‑Fi network, the router assigns it an IP address so that other devices can route traffic to it."
          ) {
            ConversationCard(
              speakers: [
                .init(systemImage: "laptopcomputer", line: "Hello! I’m new here."),
                .init(systemImage: "wifi.router.fill", line: "OK, your IP is 192.0.2.1.")
              ]
            )
          }

          chapter(
            number: "3",
            title: "But how do brand-new devices introduce themselves?",
            body: "Before they have an IP, devices still need a way to be uniquely identified. That’s where the MAC address comes in."
          ) {
            ConversationCard(
              speakers: [
                .init(systemImage: "laptopcomputer", line: "Hi! My MAC is aa:aa:aa:aa:aa:aa."),
                .init(systemImage: "laptopcomputer", line: "And mine is bb:bb:bb:bb:bb:bb."),
                .init(systemImage: "wifi.router.fill",
                      line: "Got it. aa:aa… gets 192.0.2.1, bb:bb… gets 192.0.2.2.")
              ]
            )
          }

          chapter(
            number: "4",
            title: "MAC addresses are permanent — and visible",
            body: "Each Wi‑Fi card ships with a unique MAC burnt into hardware. Because it’s announced in the clear, anyone nearby can see who is in the coffee shop at any given time."
          ) {
            ConversationCard(
              speakers: [
                .init(systemImage: "iphone",
                      line: "Hi! My MAC is dd:dd:dd:dd:dd:dd…"),
                .init(systemImage: "iphone",
                      line: "…uh, I mean ee:ee:ee:ee:ee:ee — really!")
              ],
              note: "iPhones already randomize their MAC. Macs do not."
            )
          }

          chapter(
            number: "5",
            title: "LinkLiar lets your Mac do the same",
            body: "macOS supports changing the announced MAC address, but the workflow is hidden. LinkLiar gives you a one-click way to randomize or restore it whenever you like."
          ) {
            ConversationCard(
              speakers: [
                .init(systemImage: "laptopcomputer",
                      line: "Hi! My MAC is ff:ff:ff:ff:ff:ff… trust me."),
                .init(systemImage: "wifi.router.fill",
                      line: "Welcome, stranger.")
              ]
            )
          }

          benefitsSection

          callout
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }

    // MARK: - Hero

    private var hero: some View {
      HStack(spacing: 16) {
        ZStack {
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(
              colors: [Color.accentColor.opacity(0.22), Color.accentColor.opacity(0.08)],
              startPoint: .topLeading, endPoint: .bottomTrailing))
          Image(systemName: "shield.lefthalf.filled")
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: 36, weight: .semibold))
            .foregroundStyle(.tint)
        }
        .frame(width: 72, height: 72)

        VStack(alignment: .leading, spacing: 4) {
          Text("LinkLiar Local")
            .font(.title.weight(.semibold))
          Text("Manual MAC address control for macOS.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Text("Version \(state.version.formatted)")
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        Spacer(minLength: 0)
      }
    }

    // MARK: - Chapters

    @ViewBuilder
    private func chapter<Illustration: View>(
      number: String,
      title: String,
      body: String,
      @ViewBuilder illustration: () -> Illustration
    ) -> some View {
      VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
          Text(number)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.tint)
            .frame(width: 22, height: 22)
            .background(
              Circle().fill(Color.accentColor.opacity(0.16))
            )
          Text(title)
            .font(.headline)
          Spacer(minLength: 0)
        }
        Text(body)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
        illustration()
      }
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
      VStack(alignment: .leading, spacing: 10) {
        Text("What LinkLiar Can Do")
          .font(.headline)
          .padding(.top, 4)

        VStack(spacing: 10) {
          BenefitRow(
            systemImage: "shuffle",
            tint: .blue,
            title: "Randomize Private",
            description: "Generate a fresh locally-administered MAC like 02:xx:xx:xx:xx:xx."
          )
          BenefitRow(
            systemImage: "wand.and.stars",
            tint: .purple,
            title: "Randomize Vendor-like",
            description: "Look indistinguishable from a real network card by reusing an OUI from a known vendor."
          )
          BenefitRow(
            systemImage: "arrow.uturn.backward",
            tint: .indigo,
            title: "Restore Original",
            description: "Switch back to the factory hardware MAC at any time."
          )
          BenefitRow(
            systemImage: "pencil",
            tint: .teal,
            title: "Set Specific MAC",
            description: "Pin an exact MAC address — useful for testing or captive portals."
          )
        }
      }
    }

    // MARK: - Callout

    private var callout: some View {
      InfoCard(
        "Manual & local-only",
        subtitle: "LinkLiar Local never installs background services or root daemons. Every change requires your explicit approval.",
        systemImage: "lock.shield.fill",
        accent: .success
      ) {
        HStack(spacing: 12) {
          Spacer()
          Label("Open menu bar → choose an interface → pick an action.",
                systemImage: "menubar.rectangle")
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
        }
      }
    }
  }
}

// MARK: - Helpers

private struct ConversationCard: View {
  struct Speaker: Identifiable {
    let id = UUID()
    let systemImage: String
    let line: String
  }

  let speakers: [Speaker]
  var note: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 8) {
        ForEach(speakers) { speaker in
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: speaker.systemImage)
              .symbolRenderingMode(.hierarchical)
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(.secondary)
              .frame(width: 22)
            Text(speaker.line)
              .font(.system(.subheadline, design: .monospaced))
              .foregroundStyle(.primary.opacity(0.85))
              .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
          }
        }
      }

      if let note {
        HStack(spacing: 6) {
          Image(systemName: "lightbulb")
            .font(.caption)
            .foregroundStyle(.yellow)
          Text(note)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 2)
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
    )
  }
}

private struct BenefitRow: View {
  let systemImage: String
  let tint: Color
  let title: String
  let description: String

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(tint.opacity(0.15))
        Image(systemName: systemImage)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(tint)
      }
      .frame(width: 32, height: 32)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(.subheadline, weight: .semibold))
        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer(minLength: 0)
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.45))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
    )
  }
}

#Preview {
  let state = LinkState()
  return SettingsView.WelcomeView().environment(state).frame(width: 560, height: 700)
}
