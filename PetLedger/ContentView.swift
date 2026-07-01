import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        LocalWebAppView()
            .ignoresSafeArea()
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
    }
}

struct LocalWebAppView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = false

        if let webRoot = Bundle.main.url(forResource: "web", withExtension: nil),
           let indexURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") {
            webView.loadFileURL(indexURL, allowingReadAccessTo: webRoot)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
