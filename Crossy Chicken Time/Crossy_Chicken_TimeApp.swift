import SwiftUI

@main
struct Crossy_Chicken_TimeApp: App {
    @EnvironmentObject var soundManager: SoundManager
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(SoundManager.shared)
        }
    }
}
