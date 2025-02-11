import SwiftUI

struct LoadingScreen: View {
    @State private var currentWheelImageIndex = 0
    @State private var isAnimating = true
    @State private var progress: Int = 0
    @State private var isActive = false
    @State private var urlToLoad: URL?
    @AppStorage("isNeeded") private var isNeeded: Bool = false

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                if !isLandscape {
                    ZStack {
                        Image(.backgroundLoading)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1.18)
                        
                        Image(.loadingText)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width / 2, height: geo.size.height / 2)
                            .position(x: geo.size.width / 2, y: geo.size.height)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)

                        RotateDeviceScreen()
                    }
                }
            }
            if isActive {
                if !isNeeded {
                    if let url = urlToLoad {
                        // Если URL валиден
                        BrowserView(pageURL: url)
                            .onAppear {
                                isNeeded = false
                            }
                            .transition(.opacity) // Плавный переход
                            .edgesIgnoringSafeArea(.all)
                    }
                }  else {
                        // Если URL не валиден, показываем MenuView и записываем значение
                        MenuView()
                            .onAppear {
                                isNeeded = true
                            }
                            .transition(.opacity) // Плавный переход
                            .edgesIgnoringSafeArea(.all)
                            .padding()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                
            }
        }
        .onAppear() {
                    // Запускаем проверку URL перед переходом
                    Task {
                        // Имитация асинхронного запроса к серверу для проверки URL
                        let validURL = await NetworkManager.isURLValid() // Проверяем, валиден ли URL

                        if validURL, let validLink = URL(string: urlForValidation) {
                            // Если URL валиден, передаем его в urlToLoad
                            self.urlToLoad = validLink
                           
                                withAnimation {
                                    isNeeded = true
                                    isActive = true
                                }
                            
                        } else {
                          
                            self.urlToLoad = URL(string: urlForValidation)
                            isNeeded = false
                            isActive = true
                            
                            
                        }
                    }
        }
    }
}


#Preview {
    LoadingScreen()
}

