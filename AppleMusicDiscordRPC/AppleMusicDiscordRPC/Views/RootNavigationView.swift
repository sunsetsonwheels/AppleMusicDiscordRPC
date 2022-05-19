import SwiftUI

struct RootNavigationView: View {
    @Binding var selectedView: AppView?
    @ObservedObject var rpcObservable: DiscordRPCObservable
    @ObservedObject var sparkleObservable: SparkleObservable

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    tag: AppView.rpcStatus,
                    selection: self.$selectedView,
                    destination: {
                        RPCStatusView(rpcObservable: self.rpcObservable)
                    }
                ) {
                    Label("Status", systemImage: "info.circle")
                }
                NavigationLink(
                    tag: AppView.preferences,
                    selection: self.$selectedView,
                    destination: {
                        PreferencesView(
                            rpcObservable: self.rpcObservable,
                            sparkleObservable: self.sparkleObservable
                        )
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
