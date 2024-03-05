import SwiftUI
import ComposableArchitecture

@main
struct GlobalSharedStateApp: App {
    private let store: StoreOf<AppReducer> = {
        @Dependency(\.playerState) var playerState
        
        return .init(
            initialState: .init(playerState: .init(mode: playerState.get().mode)), 
            reducer: { AppReducer() }
        )
    }()
    
    var body: some Scene {
        RootScene(store: store)
    }
}
