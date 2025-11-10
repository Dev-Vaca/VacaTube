//
//  ContentView.swift
//  VacaTube
//
//  Created by Julio César Vaca García on 10/11/25.
//

import SwiftUI
import WebKit

// MARK: - Vista principal
struct ContentView: View {
    var body: some View {
        NavigationView {
            YouTubeBrowserView()
                .navigationTitle("VacaTube")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - WebView para navegar en YouTube
struct YouTubeBrowserView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: YouTubeBrowserView
        
        init(parent: YouTubeBrowserView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let urlString = navigationAction.request.url?.absoluteString,
               urlString.contains("watch?v=") {
                
                if let id = extractYouTubeID(from: urlString),
                   let purified = purifiedURL(for: id) {
                    
                    // Cargar versión limpia del video sin anuncios
                    webView.load(URLRequest(url: purified))
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        // Extraer el ID del video de una URL de YouTube
        func extractYouTubeID(from urlString: String) -> String? {
            guard let url = URL(string: urlString) else { return nil }
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                return queryItems.first(where: { $0.name == "v" })?.value
            }
            return nil
        }
        
        // Generar URL limpia sin anuncios
        func purifiedURL(for id: String) -> URL? {
            URL(string: "https://www.youtube-nocookie.com/embed/\(id)?autoplay=1")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Cargar la página principal de YouTube
        if let url = URL(string: "https://www.youtube.com") {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Vista previa
#Preview {
    ContentView()
}
