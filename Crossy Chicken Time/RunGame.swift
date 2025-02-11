import SwiftUI

struct RunGame: View {
    @State private var chickenPosition: CGPoint = .zero
    @State private var coins: [CGPoint] = []
    @State private var lukeObstacles: [CGPoint] = []
    @State private var finishPosition: CGPoint?
    @State private var score: Int = 0
    @State private var lives: Int = 3
    @State private var gameTimer: Timer?
    
    @State private var gameState: String = "playing"
    @State private var totalCoinsSpawned: Int = 0
    @State private var totalLukesSpawned: Int = 0
    @State private var fallingSpeed: CGFloat = 2.0
    @AppStorage("score") var savedCoins: Int = 1
    
    let maxCoins = 100
    let maxLukes = 40
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if !isLandscape {
                    ZStack {
                        // Playe
                        Image("chicken")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .position(chickenPosition)
                            .onAppear {
                                chickenPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 50)
                            }
                        
                        // Coins
                        ForEach(coins.indices, id: \.self) { index in
                            Image("x")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .position(coins[index])
                        }
                        
                        // Luke Obstacles
                        ForEach(lukeObstacles.indices, id: \.self) { index in
                            Image("luke")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .position(lukeObstacles[index])
                        }
                        
                        // Finish Line
                        if let finishPos = finishPosition {
                            Image("finish")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width)
                                .position(finishPos)
                        }
                        
                        // Lives
                        
                            // Lives
                            Image("life\(lives)")
                                .resizable()
                                .frame(width: 200, height: 70)
                                .position(x: geometry.size.width / 2, y: 30)
                        
                        
                        // Game Over or Win Scree
                        if gameState != "playing" {
                            if (gameState == "win") {
                                Image(.backgroundWin)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(1.8)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                
                                WinView()
                                .onAppear {
                                    gameTimer?.invalidate()
                                }
                            } else {
                                
                                Image(.backgroundMenu)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(1.8)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                
                                LoseView(retryAction: { restartGame(geometry: geometry) })
                                    .onAppear {
                                        gameTimer?.invalidate()
                                    }
                            }
                            
                                
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(
                        Image("backgroundGame")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .scaleEffect(1.1)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                chickenPosition.x = value.location.x
                            }
                    )
                    .onAppear {
                        startGame(geometry: geometry)
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        RotateDeviceScreen()
                    }
                }
            }
            .overlay(
                ZStack {
                    Image(.back)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .position(x: geometry.size.width / 15, y: geometry.size.height / 40)
                        .onTapGesture {
                            NavResult.shared.currentScreen = .MENU
                        }
                }
            )
        }
    }
    
    func startGame(geometry: GeometryProxy) {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            if gameState != "playing" {
                timer.invalidate()
                return
            }
            
            // Ускорение падения предметов со временем
            if fallingSpeed < 5 {
                fallingSpeed += 0.005
            }
            
            // Спавн монет и люков (ограниченное количество)
            if Int.random(in: 0...100) < 70, totalCoinsSpawned < maxCoins { // 70% шанс появления монеты
                let newCoinPosition = CGPoint(x: CGFloat.random(in: 0...geometry.size.width), y: 0)
                if !checkOverlapWithObjects(position: newCoinPosition) {
                    coins.append(newCoinPosition)
                    totalCoinsSpawned += 1
                }
            } else if Int.random(in: 0...100) < 20, totalLukesSpawned < maxLukes { // 20% шанс появления люка
                let newLukePosition = CGPoint(x: CGFloat.random(in: 0...geometry.size.width), y: 0)
                if !checkOverlapWithObjects(position: newLukePosition) {
                    lukeObstacles.append(newLukePosition)
                    totalLukesSpawned += 1
                }
            }
            
            // Движение монет
            coins = coins.map { CGPoint(x: $0.x, y: $0.y + fallingSpeed) }.filter { $0.y < geometry.size.height }
            
            // Проверка на столкновение с монетами
            coins.removeAll { coin in
                let collision = checkCollision(
                    rect1: CGRect(x: chickenPosition.x - 25, y: chickenPosition.y - 25, width: 50, height: 50),
                    rect2: CGRect(x: coin.x - 15, y: coin.y - 15, width: 30, height: 30)
                )
                if collision { score += 1 }
                return collision
            }
            
            // Движение люков
            lukeObstacles = lukeObstacles.map { CGPoint(x: $0.x, y: $0.y + fallingSpeed) }.filter { $0.y < geometry.size.height }
            
            // Проверка на столкновение с люками
            lukeObstacles.removeAll { luke in
                let collision = checkCollision(
                    rect1: CGRect(x: chickenPosition.x - 25, y: chickenPosition.y - 25, width: 50, height: 50),
                    rect2: CGRect(x: luke.x - 15, y: luke.y - 15, width: 30, height: 30)
                )
                if collision {
                    lives -= 1
                    if lives <= 0 {
                        gameState = "lose"
                        timer.invalidate()
                    }
                }
                return collision
            }
            
            // Спавн финиша
            if score >= 15 && finishPosition == nil {
                finishPosition = CGPoint(x: geometry.size.width / 2, y: 0)
            }
            
            // Движение финиша
            if let finishPos = finishPosition {
                finishPosition!.y += fallingSpeed
                if checkCollision(rect1: CGRect(x: chickenPosition.x - 25, y: chickenPosition.y - 25, width: 50, height: 50),
                                 rect2: CGRect(x: finishPos.x - geometry.size.width / 2, y: finishPos.y - 10, width: geometry.size.width, height: 20)) {
                    gameState = "win"
                    savedCoins += 3
                    timer.invalidate()
                }
            }
        }
    }
    
    func restartGame(geometry: GeometryProxy) {
        // Сбрасываем состояние игры
        chickenPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 50)
        coins.removeAll()
        lukeObstacles.removeAll()
        finishPosition = nil
        score = 0
        lives = 3
        gameState = "playing"
        totalCoinsSpawned = 0
        totalLukesSpawned = 0
        fallingSpeed = 2.0

        // Запускаем игру заново
        startGame(geometry: geometry)
    }
    
    func checkCollision(rect1: CGRect, rect2: CGRect) -> Bool {
        return rect1.intersects(rect2)
    }
    
    func checkOverlapWithObjects(position: CGPoint) -> Bool {
        return coins.contains(where: { abs($0.x - position.x) < 50 }) || lukeObstacles.contains(where: { abs($0.x - position.x) < 50 })
    }
}


struct LoseView: View {
    var retryAction: () -> Void

    var body: some View {
        ZStack {
            Image(.losePlate)
                .resizable()
                .scaledToFit()
                .frame(width: 250)

            Image(.tryAgainBtn)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 90)
                .onTapGesture {
                    retryAction()
                }
                .padding(.top, 120)
        }
    }
}

struct WinView: View {
//    var retryAction: () -> Void

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
    RunGame()
}

