import SwiftUI
import ComposableArchitecture

struct MainView: View {
    let store: StoreOf<MainReducer>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Main player view with a list of audio clips")
                Spacer()
                PlayerView(state: store.playerState.mode) {
                    switch store.playerState.mode {
                    case .playing:
                        store.send(.playbackModeChanged(.stopped))
                    case .stopped:
                        store.send(.playbackModeChanged(.playing))
                    case .paused:
                        store.send(.playbackModeChanged(.playing))
                    }
                }
                .padding(.bottom, 16)
            }
            .task { await store.send(.task).finish() }
        }
    }
}

struct PlayerView: View {
    let state: PlayerState.Mode
    let onMainAction: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.windowBackgroundColor))
            HStack {
                buttonWithIconName("arrow.counterclockwise") {}
                Spacer()
                switch state {
                case .paused:
                    buttonWithIconName("play.circle.fill", action: onMainAction)
                case .playing:
                    buttonWithIconName("stop.circle.fill", action: onMainAction)
                case .stopped:
                    buttonWithIconName("play.circle.fill", action: onMainAction)
                }
                Spacer()
                buttonWithIconName("arrow.clockwise") {}
            }
            .padding(.horizontal, 16)
        }
        .frame(width: 168, height: 50)
    }
    
    private func buttonWithIconName(_ iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            imageWithName(iconName)
        })
        .buttonStyle(.plain)
    }
    
    private func imageWithName(_ iconName: String) -> some View {
        Image(systemName: iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
}

#Preview {
    PlayerView(state: .playing) {}
}

#Preview {
    MainView(
        store: Store(
            initialState: .init(playerState: .init(mode: .playing)),
            reducer: { MainReducer() }
        )
    )
}
