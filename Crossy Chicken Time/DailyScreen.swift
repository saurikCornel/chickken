import SwiftUI

struct DailyScreen: View {
    @AppStorage("score") var savedCoins: Int = 1
    @AppStorage("lastBonusTimestamp") var lastBonusTimestamp: Double = 0
    @State private var showWinView = false
    @State private var showAlert = false
    
    var canOpenBonus: Bool {
        let currentTime = Date().timeIntervalSince1970
        return (currentTime - lastBonusTimestamp) >= 86400 // 24 часа
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if !isLandscape {
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
                    
                    VStack {
                        ForEach(0..<3, id: \..self) { _ in
                            Image(.dailyEgg)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 200)
                                .onTapGesture {
                                    handleBonusTap()
                                }
                        }
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
            .fullScreenCover(isPresented: $showWinView) {
                WinViewDaily()
            }
            .alert("Already used", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private func handleBonusTap() {
        if canOpenBonus {
            savedCoins += 3
            lastBonusTimestamp = Date().timeIntervalSince1970
            showWinView = true
        } else {
            showAlert = true
        }
    }
}

struct WinViewDaily: View {
    var body: some View {
        ZStack {
            Image(.winPlate)
                .resizable()
                .scaledToFit()
                .frame(width: 250)
            
            Image(.nextBtn)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 90)
                .onTapGesture {
                    NavResult.shared.currentScreen = .MENU
                }
                .padding(.top, 370)
        }
    }
}

#Preview {
    DailyScreen()
}
