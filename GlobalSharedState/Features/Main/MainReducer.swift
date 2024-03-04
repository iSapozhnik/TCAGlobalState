import Foundation
import ComposableArchitecture
import Cocoa

@Reducer
struct MainReducer {
    
    @ObservableState
    struct State: Equatable {
        var playerState = PlayerState()
    }
    
    enum Action: Equatable {
        case onAppear
        case player(PlayerAction)
        
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
            case .player(.pause):
                state.playerState.mode = .paused
                return .none
            case .player(.play):
                state.playerState.mode = .playing
                return .none
            case .player(.stop):
                state.playerState.mode = .stopped
                return .none
                
            case let .globalPlayerStateUpdated(newState):
                state.playerState = newState
                return .none
            }
        }
        .onChange(of: \.playerState) { _, newValue in
            let _ = player.modify {
                $0 = newValue
            }
        }
    }
}
