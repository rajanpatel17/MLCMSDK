//  FullPageWebViewViewController.swift
//  MLCM

import UIKit
@preconcurrency import WebKit

class FullPageWebViewViewController: UIViewController, MLCMXIBed, WKNavigationDelegate {
    static func instantiate(htmlContent: String, webURL: String) -> Self {
        let vc = Self.instantiate()
        vc.htmlContent = htmlContent
        vc.webURL = webURL
        return vc
    }
    var htmlContent: String?
    var webURL: String?
    var completion: ((String) -> ())? = nil
    var dismissCompletion: (() -> ())? = nil
    var eventCompletion: (([String: Any]) -> ())? = nil
    
    @IBOutlet weak var webView: WKWebView!
    
    weak var delegate: FullScreenPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.configuration.userContentController.addUserScript(getZoomDisableScript())
        if htmlContent != "" {
            webView.loadHTMLString(htmlContent ?? "", baseURL: nil)
        }else if webURL != "", let url = URL(string: webURL ?? ""){
            webView.load(URLRequest(url: url))
        }
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
        
        (function() {
                    const originalAlert = window.alert;
                    window.alert = function(message) {
                        window.webkit.messageHandlers.jsAlert.postMessage(message);
                    };
                    
                    document.addEventListener('copy', function(event) {
                        let selectedText = window.getSelection().toString();
                        window.webkit.messageHandlers.clipboardHandler.postMessage(selectedText);
                    });
                })();
        """

        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(script)
        contentController.add(self, name: "clickListener")
        contentController.add(self, name: "logHandler")
        contentController.add(self, name: "jsAlert")
        contentController.add(self, name: "clipboardHandler")
        
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismissCompletion?()
        delegate?.closeButtonTapped()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url, url.scheme != "about" {
                if webURL == url.absoluteString{
                    decisionHandler(.allow)
                    return
                }else {
                    print("Clicked URL: \(url.absoluteString)")
                    self.completion?(url.absoluteString)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
}

extension FullPageWebViewViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsAlert", let alertMessage = message.body as? String {
            // Handle JavaScript Alert
            showAlert(title: "Alert", message: alertMessage)
        }
        
        if message.name == "clipboardHandler", let clipboardText = message.body as? String {
            // Handle Clipboard Copy
            UIPasteboard.general.string = clipboardText
            showAlert(title: "Code Copied", message: "\(clipboardText)")
        }
        
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

extension FullPageWebViewViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        showAlert(title: "Alert", message: message, completion: completionHandler)
    }
    
    // MARK: - Helper Alert Method
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true)
    }
}
