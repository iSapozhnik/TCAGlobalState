import Foundation
import ComposableArchitecture
import Cocoa

@Reducer
struct AppReducer {
    
    @ObservableState
    struct State: Equatable {
        var playerState = PlayerState()
    }
    
    enum Action: Equatable {
        case onAppear
        case player(PlayerAction)
        
        case settingsClicked
        case quitClicked
        
        case globalPlayerStateUpdated(PlayerState)
    }
    
    @Dependency(\.player) var player

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // first thing first - sync the global value back to the local copy
                state.playerState = player.get()
                
                // now we can start observing any changes in the global state
                // and sync with the local copy of the global state
                return .run { send in
                    for await newState in player.stream() {
                        await send(.globalPlayerStateUpdated(newState))
                    }
                }
            case let .globalPlayerStateUpdated(newState):
                state.playerState = newState
                return .none
                
            // Player actions - could be triggered form the main window or menu bar
            case .player(.play):
                print("Player started")
                state.playerState.mode = .playing

                return .none
            case .player(.pause):
                print("Player started")
                state.playerState.mode = .paused

                return .none
            case .player(.stop):
                print("Player stopped")
                state.playerState.mode = .stopped
                return .none
                
            // Menu bar actions
            case .settingsClicked:
                // Open app settings here
                return .none
            case .quitClicked:
                NSApplication.shared.terminate(nil)
                return .none
            }
        }
        // Sync the local copy of the state with the global one
        .onChange(of: \.playerState) { _, newValue in
            let _ = player.modify { $0 = newValue }
        }
    }
}
