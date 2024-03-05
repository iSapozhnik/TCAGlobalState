import SwiftUI
import ComposableArchitecture

struct MainView: View {
    let store: StoreOf<MainReducer>
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter
    }()
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Main player view with a list of audio clips")
                Spacer()
                Text(formatter.string(from: store.playerState.duration) ?? "00:00")
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.windowBackgroundColor))
            HStack {
                buttonWithIconName("gobackward.15", width: 20) {}
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
                buttonWithIconName("goforward.15", width: 20) {}
            }
            .padding(.horizontal, 10)
        }
        .frame(width: 168, height: 40)
    }
    
    private func buttonWithIconName(
        _ iconName: String,
        width: CGFloat = 24,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action, label: {
            imageWithName(iconName, width: width)
        })
        .buttonStyle(.plain)
    }
    
    private func imageWithName(
        _ iconName: String,
        width: CGFloat
    ) -> some View {
        Image(systemName: iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: width)
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
