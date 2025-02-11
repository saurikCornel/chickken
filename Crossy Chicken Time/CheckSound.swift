import Foundation
import SwiftUI

class CheckingSound: ObservableObject {
    @AppStorage("musicEnabled") var musicEnabled: Bool = false {
        didSet {
            SoundManager.shared.isSoundOn = musicEnabled
        }
    }
    @AppStorage("vibroEnabled") var vibroEnabled: Bool = false
    @AppStorage("soundEnabled") var soundEnabled: Bool = false
}
