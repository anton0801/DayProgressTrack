import SwiftUI
import WebKit
import Combine

struct HistoryView: View {
    let goal: Goal
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.deepBlue.ignoresSafeArea()
                
                if goal.history.isEmpty {
                    VStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondaryText)
                        
                        Text("No history yet")
                            .font(.system(size: 18))
                            .foregroundColor(.secondaryText)
                            .padding(.top)
                    }
                } else {
                    List {
                        ForEach(goal.history.sorted(by: { $0.date > $1.date })) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(formatDate(entry.date))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Text("+\(Int(entry.value))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.mintAccent)
                                }
                                
                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondaryText)
                                }
                            }
                            .listRowBackground(Color.cardBlue)
                        }
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
            }
            .navigationTitle("Progress History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ProgressContentView: View {
    
    @State private var activeEndpoint: String? = ""
    @State private var webViewReady = false
    
    var body: some View {
        ZStack {
            if webViewReady, let urlString = activeEndpoint, let url = URL(string: urlString) {
                ProgressWebContainer(targetURL: url)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            prepareWebView()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in
            refreshWebView()
        }
    }
    
    private func prepareWebView() {
        let temporary = UserDefaults.standard.string(forKey: "temp_url")
        let stored = UserDefaults.standard.string(forKey: "dpt_primary_endpoint") ?? ""
        
        activeEndpoint = temporary ?? stored
        webViewReady = true
        
        if temporary != nil {
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
    
    private func refreshWebView() {
        if let temporary = UserDefaults.standard.string(forKey: "temp_url"), !temporary.isEmpty {
            webViewReady = false
            activeEndpoint = temporary
            UserDefaults.standard.removeObject(forKey: "temp_url")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                webViewReady = true
            }
        }
    }
}

extension ProgressCoordinator: WKUIDelegate {
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil else {
            return nil
        }
        
        let popupView = WKWebView(frame: webView.bounds, configuration: configuration)
        popupView.navigationDelegate = self
        popupView.uiDelegate = self
        popupView.allowsBackForwardNavigationGestures = true
        
        webView.addSubview(popupView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.topAnchor.constraint(equalTo: webView.topAnchor),
            popupView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            popupView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ])
        
        let dismissGesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(dismissPopup(_:))
        )
        dismissGesture.edges = .left
        popupView.addGestureRecognizer(dismissGesture)
        
        popupStack.append(popupView)
        
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" {
            popupView.load(navigationAction.request)
        }
        
        return popupView
    }
    
    @objc private func dismissPopup(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        
        if let lastPopup = popupStack.last {
            lastPopup.removeFromSuperview()
            popupStack.removeLast()
        } else {
            webInstance?.goBack()
        }
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
