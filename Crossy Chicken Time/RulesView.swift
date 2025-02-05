import SwiftUI
import WebKit

struct BrowserViews: UIViewRepresentable {
    let pageURL: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: pageURL))
    }
}

struct RulesView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let validURL = Bundle.main.url(forResource: "howtoplay", withExtension: "html") {
                    BrowserViews(pageURL: validURL)
                } else {
                    Text("howtoplay.html not found in Bundle")
                        .foregroundColor(.red)
                        .font(.headline)
                }
            }
            .overlay(
                ZStack {
                    Image(.back)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .position(x: geometry.size.width / 9, y: geometry.size.height / 9)
                        .onTapGesture {
                            NavResult.shared.currentScreen = .MENU
                        }
                }
            )
        }
    }
}

#Preview {
    RulesView()
}
