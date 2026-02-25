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
        floatingView.dismissCompletion = { self.dismissCompletion?() }
        
        // Add WKWebView
        if htmlContent != "" {
            floatingView.webView.loadHTMLString(htmlContent, baseURL: nil)
            fullScreenPopup = FullPageWebViewViewController.instantiate(htmlContent: htmlContent, webURL: "")
            fullScreenPopup?.delegate = self
        }else if webURL != "", let url = URL(string: webURL){
            floatingView.webView.load(URLRequest(url: url))
            fullScreenPopup = FullPageWebViewViewController.instantiate(htmlContent: "", webURL: webURL)
            fullScreenPopup?.delegate = self
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
        fullScreenPopup.dismissCompletion = { self.dismissCompletion?() }
        expandCompletion?()
        superVC?.present(fullScreenPopup, animated: true, completion: nil)
    }
    
    func closeButtonTapped() {
        vcHtmlContent = ""
        vcWebURL = ""
        floatingView?.removeFromSuperview()
        fullScreenPopup?.dismiss(animated: true)
    }

    func minimizeButtonTapped() {
        guard let floatingView = floatingView else { return }
        fullScreenPopup?.dismiss(animated: true)
        superVC?.view.addSubview(floatingView)
    }
}



protocol FullScreenPopupDelegate: AnyObject {
    func closeButtonTapped()
    func minimizeButtonTapped()
    func maximizeButtonTapped()
}

class FloatingView: UIView {
    
    weak var delegate: FullScreenPopupDelegate?
    
    var closeButton: UIButton!
    var maximizeButton: UIButton!
    var webView: WKWebView!
    var eventCompletion: (([String:Any]) -> ())? = nil
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
            webView.isUserInteractionEnabled = false // Enable interaction for autoplay
            
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
        dismissCompletion?()
        delegate?.closeButtonTapped()
    }
    
    @objc private func maximizeButtonTapped() {
        delegate?.maximizeButtonTapped()
    }
}

extension FloatingView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler", let messageBody = message.body as? String {
            print("JavaScript logged: \(messageBody)")
            if let jsonData = messageBody.data(using: .utf8) {
                do {
                    if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        print("swift data =====>>> ", jsonDictionary)
                        if (jsonDictionary["eventName"] ?? "") as? String != ""{
                            self.eventCompletion?(jsonDictionary)
                        }
                    }
                } catch {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            } else {
                print("Failed to convert string to data.")
            }
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
