import Foundation
import SwiftUI


struct RootView: View {
    @ObservedObject var nav: NavResult = NavResult.shared
    var body: some View {
        switch nav.currentScreen {
                                        
        case .MENU:
            MenuView()
        case .LOADING:
            LoadingScreen()
        case .RULES:
            RulesView()
        case .SETTINGS:
            SettingsView()
        case .GAME2048:
            Game2048()
        case .RUNGAME:
            RunGame()
        case .JUMPGAME:
            JumpGame()
        case .DAILY:
            DailyScreen()
        case .BEGIN:
            BeginningGame()
            
        }

    }
}
