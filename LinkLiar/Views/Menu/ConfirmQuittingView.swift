// Copyright (c) halo https://github.com/halo/LinkLiar
// SPDX-License-Identifier: MIT

import SwiftUI

struct ConfirmQuittingView: View {
  @Environment(LinkState.self) private var state

  var body: some View {
    if state.wantsToQuit {
      VStack {
        Divider().padding(.top, 3).padding(.bottom, 5)

        Image(systemName: "door.right.hand.closed")
          .font(.system(size: 40))
          .padding(.bottom, 4)

        Text("A MAC change is still in progress.")
          .padding(.bottom, 4)

        Button(action: Controller.quitForReal) {
          Text("Quit Anyway")
        }.padding(.bottom, 4)
          .buttonStyle(.borderedProminent)

        Button(action: { Controller.wantsToStay(state) }, label: {
          Text("Cancel")
        }).padding(.bottom, 4)
          .buttonStyle(.plain)
      }
    }
  }
}

#Preview {
  let state = LinkState()
  state.wantsToQuit = true
  return ConfirmQuittingView().environment(state).frame(width: 200)
}
