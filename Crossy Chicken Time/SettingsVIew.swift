import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = CheckingSound()
    @EnvironmentObject var soundManager: SoundManager

    var body: some View {
        GeometryReader { geometry in
            var isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if !isLandscape {
                    ZStack {
                        VStack {
                            HStack {
                                Image("back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        NavResult.shared.currentScreen = .MENU
                                    }
                                Spacer()
                            }
                            Spacer()
                        }

                        Image(.settingsPlate)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 450)

                        VStack(spacing: 60) {
                            HStack(spacing: 20) {
                                Image(.musicLogo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 80)

//                                if settings.musicEnabled {
                                    Image(.soundDegr)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130, height: 80)
                                        .overlay(
                                            ZStack {
                                                // Кнопка "минус"
                                                Image(.minus)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .position(x: 12, y: 5)
                                                    .onTapGesture {
                                                        soundManager.decreaseVolume()
                                                    }

                                                // Кнопка "плюс"
                                                Image(.plus)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .position(x: 112, y: 5)
                                                    .onTapGesture {
                                                        soundManager.increaseVolume()
                                                    }

                                                // Отображение палочек громкости
                                                ForEach(0..<10) { index in
                                                    if Float(index) / 10.0 < soundManager.volume {
                                                        Image(.value)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 10, height: 23)
                                                            .position(
                                                                x: 20 + CGFloat(index) * 10,
                                                                y: 38
                                                            )
                                                    }
                                                }
                                            }
                                        )
//                                }
                            }

                            HStack(spacing: 40) {
                                Image(.vibroLogo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 80)

                                if settings.vibroEnabled {
                                    Image(.soundOff)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 110, height: 80)
                                        .onTapGesture {
                                            settings.vibroEnabled.toggle()
                                        }
                                } else {
                                    Image(.soundOn)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 110, height: 80)
                                        .onTapGesture {
                                            settings.vibroEnabled.toggle()
                                        }
                                }
                            }
                        }
                        .padding(.top, 110)
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)

                        RotateDeviceScreen()
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundMenu)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SoundManager.shared)
}
