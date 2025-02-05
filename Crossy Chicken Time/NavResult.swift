import Foundation


enum AvailableScreens {
    case MENU
    case LOADING
    case RULES
    case SETTINGS
    case GAME2048
    case RUNGAME
    case JUMPGAME
}

class NavResult: ObservableObject {
    @Published var currentScreen: AvailableScreens = .MENU
    static var shared: NavResult = .init()
}
