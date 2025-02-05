import Foundation
import SwiftUI
import WebKit

struct BrowserView: UIViewRepresentable {
    
    
    let pageURL: URL
    
    
    
    var enableSwipeNavigation: Bool = true

    func makeUIView(context: Context) -> WKWebView {
        
        
        let webBrowser = WKWebView()
        
        
        
        
        
        webBrowser.allowsBackForwardNavigationGestures = enableSwipeNavigation
        webBrowser.uiDelegate = context.coordinator
        
        
        
        
        
        return webBrowser
    }

    func updateUIView(_ webBrowser: WKWebView, context: Context) {
        let urlRequest = URLRequest(url: pageURL)
        
        
        
        
        
        
        webBrowser.load(urlRequest)
    }
    
    func makeCoordinator() -> BrowserCoordinator {
        
        
        
        
        
        
        BrowserCoordinator(self)
    }
    
    class BrowserCoordinator: NSObject, WKUIDelegate {
        
        
        
        
        
        var parentView: BrowserView

        init(_ parentView: BrowserView) {
            
            
            
            
            self.parentView = parentView
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                
                
                
                
                
                
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

struct BrowserViewWrapper: View {
    
    
    
    
    @State private var shouldShowBrowser = true
    var link: String = ""
    
    
    
    

    var body: some View {
        if let safeURLString = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           
            
            
            
            
           let webPageURL = URL(string: safeURLString) {
            BrowserView(pageURL: webPageURL)
                .onDisappear {
                    
                    
                    
                    
                    
                    shouldShowBrowser = true
                }
        }
    }
}
