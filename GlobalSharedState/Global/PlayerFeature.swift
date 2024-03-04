import Foundation
import ComposableArchitecture

@Reducer
struct PalyerFeature {
    struct State: Equatable {
        var player = PlayerState()
    }
    
    enum Action: Equatable {
        case play
        case pause
        case stop
        
        enum DelegateAction: Equatable {
            case didStop
        }
    }
}
