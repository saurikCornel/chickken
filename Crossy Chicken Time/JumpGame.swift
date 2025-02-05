import SwiftUI

enum GameStatus {
    case playing, won, lost
}

struct JumpGame: View {
    let probabilities: [Double] = [0.05, 0.07, 0.1, 0.15, 0.22, 0.3]
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State private var directions: [Bool] = []
    @State private var gameStatus: GameStatus = .playing
    @State private var isTimerActive = false
    @State private var startTime: Date?
    @State private var timerProgress: CGFloat = 0
    @State private var failedLevel: Int?
    @State private var failedDirection: Bool?
    
    // Индексы для отображения 3 пар люков
    var visibleHatches: ArraySlice<Double> {
        let startIndex = max(0, directions.count - 3)  // Начало для 3 пар
        let endIndex = min(startIndex + 3, probabilities.count)  // Общее количество люков
        return probabilities[startIndex..<endIndex]
    }
    
    var body: some View {
            GeometryReader { geo in
                let sectionHeight = geo.size.height / 6  // Разделение экрана на 6 частей
                ZStack {
                // Отображаем 3 пары люков
                ForEach(Array(visibleHatches.enumerated()), id: \.offset) { index, probability in
                    let level = max(0, directions.count - 3) + index
                    let yPos = sectionHeight * (CGFloat(2 - index) + 0.5)  // Расстояние между парами
                    
                    HatchView(
                        isOpen: failedLevel == level && failedDirection == false,
                        position: CGPoint(x: geo.size.width * 0.25, y: yPos)
                    )
                    HatchView(
                        isOpen: failedLevel == level && failedDirection == true,
                        position: CGPoint(x: geo.size.width * 0.75, y: yPos)
                    )
                    
                    Text(String(format: "%.2fx", probability))
                        .font(.headline)
                        .foregroundColor(.white)
                        .position(x: geo.size.width / 2, y: yPos + 10)
                    
                    // Разделение между парами люков
                    if index < visibleHatches.count - 1 {
                        Path { path in
                            let startX: CGFloat = 0
                            let endX: CGFloat = geo.size.width
                            let yPosition = yPos + sectionHeight / 2
                            path.move(to: CGPoint(x: startX, y: yPosition))
                            path.addLine(to: CGPoint(x: endX, y: yPosition))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(.white)
                    }
                }
//                .padding(.top, 40)
                
                // Отображаем курицу
                ChickenView(position: chickenPosition(in: geo))
                
                // Прогресс-бар
                Rectangle()
                    .frame(width: geo.size.width * timerProgress, height: 5)
                    .foregroundColor(.blue)
                    .position(x: geo.size.width / 2, y: 800)
                
                // Кнопки управления
                if gameStatus == .playing {
                    HStack(spacing: geo.size.width * 0.2) {
                        Button(action: { chooseDirection(false) }) {
                            Image("arrow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.12, height: geo.size.width * 0.12)
                        }
                        .disabled(isTimerActive)
                        
                        Button(action: { chooseDirection(true) }) {
                            Image("arrow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.12, height: geo.size.width * 0.12)
                        }
                        .disabled(isTimerActive)
                    }
                    .padding(.bottom, geo.size.height * 0.05)
                    .position(x: geo.size.width / 2, y: geo.size.height - geo.size.height * 0.1)
                }
                
                // Сообщение о победе или поражении
                if gameStatus == .won {
                    Image(.backgroundWin)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.8)
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    WinView()
                } else if gameStatus == .lost {
                    Image(.backgroundMenu)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.8)
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    LoseView(retryAction: { restartGame(geometry: geo) })
                }
            }
                .frame(width: geo.size.width, height:
                    geo.size.height)
                .background(
                    Image("backgroundJumpGame")
                         .resizable()
                         .scaledToFill()
                         .ignoresSafeArea()
                         .scaleEffect(1.1)
                )
                .overlay(
                    ZStack {
                        Image(.back)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .position(x: geo.size.width / 15, y: geo.size.height / 40)
                            .onTapGesture {
                                NavResult.shared.currentScreen = .MENU
                            }
                    }
                )
        }
        .onReceive(timer) { _ in
            guard gameStatus == .playing, isTimerActive, let startTime = startTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            timerProgress = min(CGFloat(elapsed / 5), 1)
            
            if timerProgress >= 1 {
                isTimerActive = false
            }
        }
        .onAppear {
            if directions.isEmpty && gameStatus == .playing {
                startTimer()
            }
        }
    }
    
    private func restartGame(geometry: GeometryProxy) {
        directions.removeAll()
        gameStatus = .playing
        isTimerActive = false
        failedLevel = nil
        failedDirection = nil
        timerProgress = 0
        startTimer()
    }
    
    private func chickenPosition(in geo: GeometryProxy) -> CGPoint {
        let sectionHeight = geo.size.height / 6
        if directions.isEmpty {
            return CGPoint(x: geo.size.width / 2, y: geo.size.height - sectionHeight / 2)
        } else {
            let level = max(0, directions.count - 1)
            let isRight = directions.last ?? false
            let yPosition = sectionHeight * (2.5 - CGFloat(level))
            
            // Ограничиваем Y-позицию, чтобы курица не выходила за экран
            let clampedYPosition = min(max(yPosition, sectionHeight / 2), geo.size.height - sectionHeight / 2)
            
            return CGPoint(
                x: isRight ? geo.size.width * 0.75 : geo.size.width * 0.25,
                y: clampedYPosition
            )
        }
    }
    
    private func startTimer() {
        startTime = Date()
        isTimerActive = true
        timerProgress = 0
    }
    
    private func chooseDirection(_ isRight: Bool) {
        guard !isTimerActive, gameStatus == .playing else { return }
        
        let currentLevel = directions.count
        guard currentLevel < probabilities.count else { return }
        
        let probability = probabilities[currentLevel]
        if Double.random(in: 0...1) < probability {
            gameStatus = .lost
            failedLevel = currentLevel
            failedDirection = isRight
        } else {
            directions.append(isRight)
            if directions.count >= probabilities.count {
                gameStatus = .won
            } else {
                startTimer()
            }
        }
    }
}

struct HatchView: View {
    let isOpen: Bool
    let position: CGPoint
    
    var body: some View {
        Image(isOpen ? "lyck_open" : "lyck")
            .resizable()
            .frame(width: 100, height: 100)
            .position(position)
    }
}

struct ChickenView: View {
    let position: CGPoint
    
    var body: some View {
        Image("chickenjump")
            .resizable()
            .frame(width: 60, height: 60)
            .position(position)
            .animation(.easeInOut, value: position)
    }
}

#Preview {
    JumpGame()
}
