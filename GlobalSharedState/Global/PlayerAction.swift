import Foundation

enum PlayerAction: Equatable {
    case play
    case pause
    case stop
    
    enum DelegateAction: Equatable {
        case didStop
    }
}
