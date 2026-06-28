# LinkLiar Local

LinkLiar Local is a local-only macOS menu bar app for manually changing the MAC
address of Wi-Fi and Ethernet interfaces.

This project is a security-hardened fork of the original
[halo/LinkLiar](https://github.com/halo/LinkLiar). The original app, icon work,
and MIT-licensed foundation belong to halo and the LinkLiar contributors. This
fork keeps the useful manual interface controls and removes the privileged
background automation surface.

## What This Fork Does

- Lists local network interfaces with current and original MAC addresses.
- Lets you manually choose an action per interface:
  - `Randomize Private`
  - `Randomize Vendor-like`
  - `Restore Original`
  - `Set Specific MAC`
  - `Copy MAC`
- Prompts for administrator approval for each MAC change.
- Disassociates Wi-Fi before attempting a Wi-Fi MAC change.
- Stores config and logs under your user Library:
  - `~/Library/Application Support/LinkLiarLocal/config.json`
  - `~/Library/Logs/LinkLiarLocal/linkliar.log`
- Redacts MAC-looking values in logs by default.

## Security Model

LinkLiar Local is intentionally manual and local-only.

Removed from the original runtime design:

- Persistent root daemon
- Bundled LaunchDaemon
- XPC Mach service
- Background policy engine
- SSID/access-point rules
- `airport` command-line dependency
- GitHub updater checks and community/network links in the app

It does not fetch updates, policy data, or vendor data at runtime.

The privileged action path is limited to this command shape:

```bash
/sbin/ifconfig <enN> ether <mac>
```

Before any administrator prompt, the app validates that the selected BSD
interface name matches `en` followed by digits, such as `en0`, and that the
target MAC address parses as a normalized MAC address.

The app does not install a background service. After quitting the app, there
should be no long-running root LinkLiar process.

## Requirements

- macOS 14.0 or later
- Xcode
- Administrator privileges when applying a MAC change

macOS and hardware support for MAC spoofing varies. Some interfaces, chips, or
network states may refuse MAC changes even when the command is valid.

## Build From Source

Clone this fork:

```bash
git clone https://github.com/sachinmour/LinkLiarLocal.git
cd LinkLiarLocal
```

Build the release app:

```bash
xcodebuild -project LinkLiar.xcodeproj -scheme LinkLiar -configuration Release -derivedDataPath /private/tmp/linkliar-derived CODE_SIGNING_ALLOWED=NO build
```

The built app will be at:

```text
/private/tmp/linkliar-derived/Build/Products/Release/LinkLiar Local.app
```

This README documents source builds only. No packaged install path is promised
here.

## Usage

1. Launch `LinkLiar Local.app`.
2. Open the menu bar item.
3. Use the action menu beside a spoofable interface.
4. Approve the macOS administrator prompt when changing a MAC address.

Random modes:

- `Randomize Private` creates a locally administered unicast MAC like
  `02:xx:xx:xx:xx:xx`.
- `Randomize Vendor-like` uses bundled OUI/vendor data and generates a random
  suffix.

`Restore Original` changes the interface back to its hardware MAC address.
`Set Specific MAC` validates the address before requesting administrator
approval.

## Limitations And Safety

- Changing a Wi-Fi MAC disconnects the active Wi-Fi network briefly.
- macOS may reject MAC changes on some interfaces or while an interface is in a
  particular state.
- System Settings may still display the original hardware MAC address even when
  network traffic uses the changed MAC.
- Use this only on devices and networks where you are authorized to do so.

## Development And Verification

Build:

```bash
xcodebuild -project LinkLiar.xcodeproj -scheme LinkLiar -configuration Release -derivedDataPath /private/tmp/linkliar-derived CODE_SIGNING_ALLOWED=NO build
```

Run tests:

```bash
xcodebuild -project LinkLiar.xcodeproj -scheme LinkLiar -configuration Debug -derivedDataPath /private/tmp/linkliar-derived CODE_SIGNING_ALLOWED=NO test
```

Useful static checks for this fork:

- No active runtime references to `SMAppService`, `MachServices`,
  `LaunchDaemons`, `NSXPC`, `linkdaemon`, `URLSession`, GitHub API strings, or
  old system-wide config paths.
- No bundled `Contents/Library/LaunchDaemons`, `XPCServices`, or embedded daemon
  in the built app.
- No old `/tmp/linkliar.log`, `/tmp/linkliar.isolation.json`, or
  `/Library/Application Support/io.github.halo.LinkLiar` runtime paths in the
  release binary.
- Manual acceptance should include confirming visible actions work, invalid
  specific MAC input fails before an administrator prompt, Wi-Fi disassociates
  before a Wi-Fi MAC change, restore works, concurrent changes are disabled, and
  no background/root LinkLiar process remains after quitting.

## Credits

- Original project: [halo/LinkLiar](https://github.com/halo/LinkLiar)
- Original author and copyright: halo
- Local-only hardening fork changes: Sachin Mour

## License

MIT. See [LICENSE.txt](LICENSE.txt).
