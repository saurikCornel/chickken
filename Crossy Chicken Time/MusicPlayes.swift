import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    @Published var isSoundOn: Bool = false {
        didSet {
            if isSoundOn {
                playMusic()
            } else {
                stopMusic()
            }
        }
    }

    @Published var volume: Float = 0.0 {
        didSet {
            audioPlayer?.volume = volume
            if volume > 0 && !isSoundOn {
                isSoundOn = true
            }
            if volume == 0 && isSoundOn {
                isSoundOn = false
            }
        }
    }

    private init() {
        if let url = Bundle.main.url(forResource: "audio", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = volume
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }

    func playMusic() {
        audioPlayer?.play()
    }

    func stopMusic() {
        audioPlayer?.stop()
    }

    func increaseVolume() {
        volume = min(1.0, volume + 0.1)
    }

    func decreaseVolume() {
        volume = max(0.0, volume - 0.1)
    }
}
