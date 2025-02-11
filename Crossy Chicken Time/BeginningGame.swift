import SwiftUI

struct BeginningGame: View {
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var rotateAnimation: Double = 0.0

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
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        NavResult.shared.currentScreen = .MENU
                                    }
                                    .padding(20)

                                Spacer()

                               
                            }
                            Spacer()
                        }

                        VStack {
//                            Text("Score: \(score)")
//                                .font(.title2)
//                                .padding()
                            
                            ScoreTemplate(score: score)
                                .padding(.top, 50)
                            Spacer()
                        }

                        
                        VStack {
                            if isGameOver {
                                WinView()
                            } else {

                                GridView(grid: grid)
                                    .gesture(
                                        DragGesture()
                                            .onEnded { gesture in
                                                handleSwipe(gesture: gesture)
                                            }
                                    )
//                                    .padding()
//                                    .background(Color.blue.opacity(0.5))
//                                    .cornerRadius(15)
                            }
                        }
                        .padding()
                        .onAppear {
                            spawnRandomTile()
                            spawnRandomTile()
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
                Image(.backgroundGame1)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
                
            )

        }
    }

    private func resetGame() {
        withAnimation {
            grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
            score = 0
            isGameOver = false
        }
        spawnRandomTile()
        spawnRandomTile()
    }

    private func spawnRandomTile() {
        var emptyTiles: [(Int, Int)] = []
        for i in 0..<4 {
            for j in 0..<4 {
                if grid[i][j] == 0 {
                    emptyTiles.append((i, j))
                }
            }
        }

        if let randomTile = emptyTiles.randomElement() {
            withAnimation {
                grid[randomTile.0][randomTile.1] = [2, 4].randomElement() ?? 2
            }
        }
    }

    private func handleSwipe(gesture: DragGesture.Value) {
        let translation = gesture.translation
        let direction: String

        if abs(translation.width) > abs(translation.height) {
            direction = translation.width > 0 ? "right" : "left"
        } else {
            direction = translation.height > 0 ? "down" : "up"
        }

        withAnimation {
            moveTiles(direction: direction)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            spawnRandomTile()
            if !hasAvailableMoves() {
                isGameOver = true
            }
        }
    }

    private func moveTiles(direction: String) {
        var moved = false

        for _ in 0..<4 {
            for i in 0..<4 {
                for j in 0..<4 {
                    if grid[i][j] != 0 {
                        let (nextI, nextJ) = getNextPosition(i: i, j: j, direction: direction)
                        if isValidMove(nextI, nextJ), grid[nextI][nextJ] == 0 {
                            grid[nextI][nextJ] = grid[i][j]
                            grid[i][j] = 0
                            moved = true
                        } else if isValidMove(nextI, nextJ), grid[nextI][nextJ] == grid[i][j] {
                            grid[nextI][nextJ] *= 2
                            grid[i][j] = 0
                            score += grid[nextI][nextJ]
                            moved = true
                        }
                    }
                }
            }
        }

        if !moved {
            return
        }
    }

    private func getNextPosition(i: Int, j: Int, direction: String) -> (Int, Int) {
        switch direction {
        case "up": return (i - 1, j)
        case "down": return (i + 1, j)
        case "left": return (i, j - 1)
        case "right": return (i, j + 1)
        default: return (i, j)
        }
    }

    private func isValidMove(_ i: Int, _ j: Int) -> Bool {
        return i >= 0 && i < 4 && j >= 0 && j < 4
    }

    private func hasAvailableMoves() -> Bool {
        for i in 0..<4 {
            for j in 0..<4 {
                if grid[i][j] == 0 { return true }

                if i > 0 && grid[i][j] == grid[i - 1][j] { return true }
                if i < 3 && grid[i][j] == grid[i + 1][j] { return true }
                if j > 0 && grid[i][j] == grid[i][j - 1] { return true }
                if j < 3 && grid[i][j] == grid[i][j + 1] { return true }
            }
        }
        return false
    }
}

#Preview {
    BeginningGame()
}
