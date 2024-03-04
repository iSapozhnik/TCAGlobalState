import SwiftUI
import ComposableArchitecture

enum WindowID {
    static let main = "main"
    static let settings = "settings"
}

@MainActor
struct RootScene: Scene {
    private let store: StoreOf<AppReducer>
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        MenuBarExtra(content: content, label: label)
        Window("", id: WindowID.main) {
            WithPerceptionTracking {
                MainView(
                    store: Store(
                        initialState: .init(),
                        reducer: { MainReducer() }
                    )
                )
                .frame(width: 700, height: 530)
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.automatic)
    }
    
    init(store: StoreOf<AppReducer>) {
        self.store = store
    }
    
    private func label() -> some View {
        WithPerceptionTracking {
            Image(systemName: store.playerState.mode == .playing ? "stop.circle.fill" : "play.circle.fill")
                .onAppear {
                    store.send(.onAppear)
                    openWindow(id: WindowID.main)
                }
                .onChange(of: store.playerState.mode) { mode in
                    print("Menu bar mode chnaged: \(mode)")
                }
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        WithPerceptionTracking {
            
            Group {
                switch store.playerState.mode {
                case .playing:
                    Button(action: {
                        store.send(.player(.stop))
                    }, label: {
                        Text("Stop")
                    })
                    Button(action: {
                        store.send(.player(.pause))
                    }, label: {
                        Text("Pause")
                    })
                case .paused:
                    Button(action: {
                        store.send(.player(.play))
                    }, label: {
                        Text("Play")
                    })
                case .stopped:
                    Button(action: {
                        store.send(.player(.play))
                    }, label: {
                        Text("Play")
                    })
                }
                
                Button(action: {
                    store.send(.settingsClicked)
                }, label: {
                    Text("Settings")
                })
                .keyboardShortcut(",", modifiers: [.command])
                
                Divider()
                Button(action: {
                    store.send(.quitClicked)
                }, label: {
                    Text("Quit")
                })
                .keyboardShortcut("q", modifiers: [.command])
            }
        }
    }
}
