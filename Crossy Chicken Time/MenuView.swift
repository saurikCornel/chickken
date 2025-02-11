import SwiftUI

struct MenuView: View {
    @AppStorage("score") var savedCoins: Int = 1
    @State private var isModalPresented = false

    var body: some View {
        GeometryReader { geometry in
            var isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if !isLandscape {
                    ZStack {
                        VStack {
                            HStack  {
                                ButtonTemplateSmall(image: "rulesBtn", action: {NavResult.shared.currentScreen = .RULES})
                                Spacer()
                                ButtonTemplateBig(image: "daily", action: {NavResult.shared.currentScreen = .DAILY})
                                Spacer()
                                ButtonTemplateSmall(image: "settingsBtn", action: {NavResult.shared.currentScreen = .SETTINGS})
                            }
                            
                            Spacer()
                            
                            ButtonTemplateBig(image: "lvlBtn", action: {
                                isModalPresented.toggle()
                            })
                                .overlay(
                                    ZStack {
                                        Text("\(savedCoins)X")
                                            .foregroundStyle(.white)
                                            .fontWeight(.heavy)
                                            .font(.system(size: 30))
                                            .position(x: 75, y: 95)
                                    }
                                )
                            
                            Spacer()
                            HStack {
                                ButtonTemplateMiddle(image: "moveGameBtn", action: {NavResult.shared.currentScreen = .GAME2048})
                                
                                ButtonTemplateMiddle(image: "beginBtn", action: {NavResult.shared.currentScreen = .GAME2048})
                            }
                            
                            HStack {
                                ButtonTemplateMiddle(image: "jumpGameBtn", action: {NavResult.shared.currentScreen = .JUMPGAME})
                                Spacer()
                                ButtonTemplateMiddle(image: "runGameBtn", action: {NavResult.shared.currentScreen = .RUNGAME})
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
                
                if isModalPresented {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        Image("modal") // Заменишь на нужное изображение
                            .resizable()
                            .scaledToFit()
                         .frame(height: 300)
                        
                        Button(action: {
                            isModalPresented = false
                        }) {
                            Image("closemodal") // Заменишь на нужное изображение
                                .resizable()
                                .scaledToFit()
                                .frame(height: 70)
                        }
                        .offset(x: 150, y: -60) // Сдвигает кнопку левее и выше
                        ZStack {
                            Text("\(savedCoins)")
                                .foregroundStyle(.white)
                                .fontWeight(.heavy)
                                .font(.system(size: 30))
                        }
                        .offset(x: -4, y: -93)
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

struct ButtonTemplateSmall: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 80)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}

struct ButtonTemplateBig: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(10)
                .shadow(radius: 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}

struct ButtonTemplateMiddle: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}

#Preview {
    MenuView()
}
