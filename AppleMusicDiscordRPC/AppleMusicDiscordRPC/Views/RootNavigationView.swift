import SwiftUI

struct RootNavigationView: View {
    @Binding var selectedView: AppView?

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    tag: AppView.rpcStatus,
                    selection: self.$selectedView,
                    destination: {
                        RPCStatusView()
                    }
                ) {
                    Label("Status", systemImage: "info.circle")
                }
                NavigationLink(
                    tag: AppView.preferences,
                    selection: self.$selectedView,
                    destination: {
                        PreferencesView()
                    }
                ) {
                    Label("Preferences", systemImage: "gearshape")
                }
            }
            EmptyView()
        }
        .navigationTitle("Apple Music Discord RPC")
        .frame(width: 430, height: 350)
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView(selectedView: .constant(.rpcStatus))
    }
}
