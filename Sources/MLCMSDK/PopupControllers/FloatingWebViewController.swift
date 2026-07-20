//  FloatingWebViewController.swift
//  MLCM

import Foundation
import UIKit
import WebKit

class FloatingWebViewController{
    
    var superVC: UIViewController?
    var floatingView: FloatingView?
    var fullScreenPopup: FullPageWebViewViewController?
    var vcHtmlContent: String?
    var vcWebURL: String?
    var completion: ((String) -> ())? = nil
    var dismissCompletion: (() -> ())? = nil
    var expandCompletion: (() -> ())? = nil
    var eventCompletion: (([String: Any]) -> ())? = nil
    
    func startFloatingView(vc: UIViewController, htmlContent: String, webURL: String, showFullScreen: Bool){
        superVC = vc
        vcHtmlContent = htmlContent
        vcWebURL = webURL
        floatingView = FloatingView(frame: CGRect(x: 20, y: (superVC?.view.frame.maxY ?? 0) - 300, width: 150, height: 250))
        guard let floatingView = floatingView else { return }
        floatingView.backgroundColor = .white
        floatingView.clipsToBounds = true
        floatingView.delegate = self
        floatingView.eventCompletion = { obj in
            self.eventCompletion?(obj)
        }
        floatingView.deeplinkCompletion = { str in
            self.completion?(str)
        }
        floatingView.dismissCompletion = { self.dismissCompletion?() }
        
        let isVideo = isVideoURL(webURL)
        
        // Add WKWebView
        if htmlContent != "" {
            floatingView.webView.loadHTMLString(htmlContent, baseURL: nil)
            floatingView.closeButton.isHidden = false
            floatingView.maximizeButton.isHidden = false
            floatingView.webView.isUserInteractionEnabled = false
            fullScreenPopup = FullPageWebViewViewController.instantiate(htmlContent: htmlContent, webURL: "")
            fullScreenPopup?.delegate = self
        }else if webURL != "", let url = URL(string: webURL){
            if isVideo {
                let smallHTML = getVideoHTML(for: webURL, showControls: false)
                let fullHTML = getVideoHTML(for: webURL, showControls: true)
                floatingView.webView.loadHTMLString(smallHTML, baseURL: nil)
                fullScreenPopup = FullPageWebViewViewController.instantiate(htmlContent: fullHTML, webURL: "")
                fullScreenPopup?.delegate = self
            } else {
                floatingView.vcWebURL = webURL
                floatingView.webView.load(URLRequest(url: url))
                floatingView.closeButton.isHidden = true
                floatingView.maximizeButton.isHidden = true
                floatingView.webView.isUserInteractionEnabled = true
                fullScreenPopup = FullPageWebViewViewController.instantiate(htmlContent: "", webURL: webURL)
                fullScreenPopup?.delegate = self
            }
        }
        
        
        // Make the floating view draggable
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        floatingView.addGestureRecognizer(panGesture)
        
        if showFullScreen{
            maximizeButtonTapped()
        }else{
            superVC?.view.addSubview(floatingView)
        }
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let topView = superVC else { return }
        let translation = recognizer.translation(in: topView.view)

        guard let floatingView = recognizer.view else { return }

        let minY = topView.view.safeAreaInsets.top
        let maxY = topView.view.bounds.height - floatingView.frame.height - topView.view.safeAreaInsets.bottom
        let minX = topView.view.safeAreaInsets.left
        let maxX = topView.view.bounds.width - floatingView.frame.width - topView.view.safeAreaInsets.right

        let newX = min(max(floatingView.frame.minX + translation.x, minX), maxX)
        let newY = min(max(floatingView.frame.minY + translation.y, minY), maxY)

        floatingView.frame = CGRect(x: newX, y: newY, width: floatingView.frame.width, height: floatingView.frame.height)

        recognizer.setTranslation(CGPoint.zero, in: topView.view)
    }
    
    private func isVideoURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        var cleanURL = url
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            components.query = nil
            components.fragment = nil
            if let stripped = components.url {
                cleanURL = stripped
            }
        }
        let pathExtension = cleanURL.pathExtension.lowercased()
        let videoExtensions = ["mp4", "mov", "m4v", "3gp", "avi", "mkv", "webm", "m3u8"]
        return videoExtensions.contains(pathExtension) || urlString.contains(".mp4") || urlString.contains(".m3u8")
    }
    
    private func getVideoHTML(for videoURL: String, showControls: Bool) -> String {
        let controlsAttr = showControls ? "controls" : ""
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    background-color: black;
                    overflow: hidden;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                }
                video {
                    width: 100%;
                    height: 100%;
                    object-fit: contain;
                }
            </style>
        </head>
        <body>
            <video id="videoPlayer" playsinline autoplay muted loop \(controlsAttr) src="\(videoURL)">
                Your browser does not support the video tag.
            </video>
        </body>
        </html>
        """
    }
}

extension FloatingWebViewController: FullScreenPopupDelegate {
    func maximizeButtonTapped() {
        guard let fullScreenPopup = fullScreenPopup else { return }
        fullScreenPopup.modalPresentationStyle = .fullScreen
        fullScreenPopup.isModalInPresentation = true
        fullScreenPopup.completion = { str in
            self.completion?(str)
        }
        fullScreenPopup.eventCompletion = { obj in
            self.eventCompletion?(obj)
        }
        stopAllMediaPlayback()
        fullScreenPopup.dismissCompletion = { self.dismissCompletion?() }
        expandCompletion?()
        superVC?.present(fullScreenPopup, animated: true, completion: nil)
    }
    
    func closeButtonTapped() {
        vcHtmlContent = ""
        vcWebURL = ""
        stopAllMediaPlayback()
        floatingView?.removeFromSuperview()
        fullScreenPopup?.dismiss(animated: true)
    }

    func minimizeButtonTapped() {
        guard let floatingView = floatingView else { return }
        fullScreenPopup?.dismiss(animated: true)
        superVC?.view.addSubview(floatingView)
    }
    
    private func stopAllMediaPlayback() {
        if let floatingWebView = floatingView?.webView {
            floatingWebView.load(URLRequest(url: URL(string: "about:blank")!))
            if #available(iOS 15.0, *) {
                floatingWebView.setAllMediaPlaybackSuspended(true, completionHandler: nil)
            } else {
                let js = """
                (function() {
                    try {
                        var videos = document.querySelectorAll('video');
                        for (var i = 0; i < videos.length; i++) {
                            videos[i].pause();
                            videos[i].currentTime = 0;
                        }
                        var audios = document.querySelectorAll('audio');
                        for (var j = 0; j < audios.length; j++) {
                            audios[j].pause();
                            audios[j].currentTime = 0;
                        }
                    } catch (e) {
                        // ignore
                    }
                })();
                """
                floatingWebView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
        
        if let fullScreenWebView = fullScreenPopup?.webView {
            fullScreenWebView.load(URLRequest(url: URL(string: "about:blank")!))
            if #available(iOS 15.0, *) {
                fullScreenWebView.setAllMediaPlaybackSuspended(true, completionHandler: nil)
            } else {
                let js = """
                (function() {
                    try {
                        var videos = document.querySelectorAll('video');
                        for (var i = 0; i < videos.length; i++) {
                            videos[i].pause();
                            videos[i].currentTime = 0;
                        }
                        var audios = document.querySelectorAll('audio');
                        for (var j = 0; j < audios.length; j++) {
                            audios[j].pause();
                            audios[j].currentTime = 0;
                        }
                    } catch (e) {
                        // ignore
                    }
                })();
                """
                fullScreenWebView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
    }
}



protocol FullScreenPopupDelegate: AnyObject {
    func closeButtonTapped()
    func minimizeButtonTapped()
    func maximizeButtonTapped()
}

class FloatingView: UIView, WKNavigationDelegate {
    
    weak var delegate: FullScreenPopupDelegate?
    
    var closeButton: UIButton!
    var maximizeButton: UIButton!
    var webView: WKWebView!
    var vcWebURL: String?
    var eventCompletion: (([String:Any]) -> ())? = nil
    var deeplinkCompletion: ((String) -> ())? = nil
    var dismissCompletion: (() -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Add shadow
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        // Web View
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true // Enable inline playback
        webConfiguration.mediaTypesRequiringUserActionForPlayback = [] // Disable user action for playback
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isUserInteractionEnabled = true // Enable interaction for autoplay
        webView.navigationDelegate = self      // will compile after step 2
        webView.uiDelegate = self
        addSubview(webView)
        
        
        // Close Button
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "mlcmFilledCloseButton", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        addSubview(closeButton)
        
        // Maximize Button
        maximizeButton = UIButton(type: .custom)
        maximizeButton.setImage(UIImage(named: "maximise", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        maximizeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        maximizeButton.addTarget(self, action: #selector(maximizeButtonTapped), for: .touchUpInside)
        addSubview(maximizeButton)
        
        let contentController = self.webView.configuration.userContentController
        let scriptSource = """
            document.addEventListener('DOMContentLoaded', function() {
                document.body.addEventListener('click', function(event) {
                    var targetElement = event.target || event.srcElement;
                    var targetUrl = targetElement.href || 'No URL';
                    var onClickAction = targetElement.getAttribute('onclick') || 'No onClick Action';
                    var message = {
                        type: 'click',
                        tagName: targetElement.tagName,
                        id: targetElement.id || 'No ID',
                        className: targetElement.className,
                        outerHTML: targetElement.outerHTML.slice(0, 500),
                        url: targetUrl,
                        onClick: onClickAction
                    };
                    window.webkit.messageHandlers.clickListener.postMessage(message);

                    if (!targetUrl && targetElement.tagName === 'BUTTON') {
                        setTimeout(() => { // Delay to catch any asynchronous actions triggered by the button
                            var currentUrl = window.location.href;
                            if (currentUrl !== document.referrer) { // Check if the URL has changed
                                window.webkit.messageHandlers.clickListener.postMessage({
                                    type: 'navigation',
                                    newUrl: currentUrl
                                });
                            }
                        }, 100);
                    }
                });
            });

            // Global helper to post messages directly to Swift from frontend
            window.postAppEvent = function(data) {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.clickListener) {
                    window.webkit.messageHandlers.clickListener.postMessage(data);
                }
            };

            // Custom event listener for APP_EVENT
            window.addEventListener('APP_EVENT', function(event) {
                var message = event.detail || event;
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.clickListener) {
                    window.webkit.messageHandlers.clickListener.postMessage(message);
                }
            });

            // Override console.log
            window.originalConsoleLog = console.log;
            console.log = function(message) {
                window.webkit.messageHandlers.logHandler.postMessage(message);
                window.originalConsoleLog.apply(console, arguments);
            };
        """

        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(script)
        contentController.add(self, name: "clickListener")
        contentController.add(self, name: "logHandler")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
        
        let buttonSize = CGSize(width: 30, height: 30)
        closeButton.frame = CGRect(x: 5, y: 5, width: buttonSize.width, height: buttonSize.height)
        maximizeButton.frame = CGRect(x: bounds.width - buttonSize.width - 5, y: 5, width: buttonSize.width, height: buttonSize.height)
        //CGRect(x: 0, y: buttonSize.height + 10, width: bounds.width, height: bounds.height - buttonSize.height - 10)
    }
    
    @objc private func closeButtonTapped() {
        stopAllMediaPlayback()
        dismissCompletion?()
        delegate?.closeButtonTapped()
    }
    
    @objc private func maximizeButtonTapped() {
        stopAllMediaPlayback()
        delegate?.maximizeButtonTapped()
    }
    
    @objc private func minimizeButtonTapped() {
        stopAllMediaPlayback()
        delegate?.minimizeButtonTapped()
    }
    
    deinit {
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "clickListener")
    }
    
    private func stopAllMediaPlayback() {
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        // iOS 15+ native API
        if #available(iOS 15.0, *) {
            webView.setAllMediaPlaybackSuspended(true, completionHandler: nil)
        } else {
            // Fallback: pause all video/audio elements via JS
            let js = """
            (function() {
                try {
                    var videos = document.querySelectorAll('video');
                    for (var i = 0; i < videos.length; i++) {
                        videos[i].pause();
                        videos[i].currentTime = 0;
                    }
                    var audios = document.querySelectorAll('audio');
                    for (var j = 0; j < audios.length; j++) {
                        audios[j].pause();
                        audios[j].currentTime = 0;
                    }
                } catch (e) {
                    // ignore
                }
            })();
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url, url.scheme != "about" {
                if vcWebURL == url.absoluteString{
                    decisionHandler(.allow)
                    return
                }else {
                    print("Clicked URL: \(url.absoluteString)")
                    self.deeplinkCompletion?(url.absoluteString)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        decisionHandler(.allow)
    }
}

extension FloatingView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            if let bodyDict = message.body as? [String: Any] {
                handleReceivedEvent(bodyDict)
            } else if let messageBody = message.body as? String {
                print("JavaScript logged: \(messageBody)")
                if let jsonData = messageBody.data(using: .utf8) {
                    do {
                        if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            print("swift data =====>>> ", jsonDictionary)
                            if (jsonDictionary["eventName"] ?? "") as? String != ""{
                                self.eventCompletion?(jsonDictionary)
                            }
                        }
                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            handleReceivedEvent(jsonObject)
                        }
                    } catch {
                        print("Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            }
        } else if message.name == "clickListener" {
            if let bodyDict = message.body as? [String: Any] {
                handleReceivedEvent(bodyDict)
            } else if let bodyString = message.body as? String {
                print("JavaScript logged: \(bodyString)")
                if let jsonData = bodyString.data(using: .utf8),
                   let bodyDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    handleReceivedEvent(bodyDict)
                }
            }
        }
    }
    
    private func handleReceivedEvent(_ jsonObject: [String: Any]) {
        if let type = jsonObject["type"] as? String {
            switch type {
            case "APP_ACTION":
                self.handleAppAction(jsonObject)
            case "LINK":
                self.handleLinkAction(jsonObject)
            case "EVENT":
                self.handleAppEvents((jsonObject["payload"] as? [String: Any]) ?? [:])
            default:
                print("Unhandled action type: \(type)")
            }
        }
    }
    
    private func handleAppAction(_ jsonObject: [String: Any]) {
        if let payload = jsonObject["payload"] as? [String: Any], let value = payload["value"] as? String {
            if value.caseInsensitiveCompare("cross") == .orderedSame {
                closeButtonTapped()
            } else if value.caseInsensitiveCompare("maximize") == .orderedSame {
                maximizeButtonTapped()
            } else if value.caseInsensitiveCompare("minimize") == .orderedSame {
                minimizeButtonTapped()
            }
        }
    }
    
    private func handleAppEvents(_ jsonDictionary: [String: Any]) {
        guard let eventName = jsonDictionary["eventName"] as? String, !eventName.isEmpty else { return }
        self.eventCompletion?(jsonDictionary)
    }

    private func handleLinkAction(_ jsonObject: [String: Any]) {
        if let payload = jsonObject["payload"] as? [String: Any], let value = payload["value"] as? String {
            self.deeplinkCompletion?(value)
        }
    }
    
}

extension FloatingView: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
