//  ShowHtmlContentViewController.swift
//  MLCM


import UIKit
import WebKit

class ShowHtmlContentViewController: UIViewController, MLCMXIBed {
    
    static func instantiate(htmlContent: String, contentType: String, forceDismiss: Bool) -> Self {
        let vc = Self.instantiate()
        vc.htmlContent = htmlContent
        vc.contentType = contentType
        vc.forceDismiss = forceDismiss
        return vc
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeButton: UIButton!
    
    var htmlContent: String?
    var contentType: String?
    var forceDismiss: Bool?
    var webViewCompletion: (() -> ())? = nil
    var cancelCompletion: (() -> ())? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true){
            self.cancelCompletion?()
        }
    }
    
}

extension ShowHtmlContentViewController{
    func setupUI(){
        containerView.layer.cornerRadius = 20
        
        if isValidURL(htmlContent ?? ""), let url = URL(string: "https://www.example.com"){
            let request = URLRequest(url: url)
            webView.load(request)
        }else{
            webView.loadHTMLString(htmlContent ?? "", baseURL: nil)
        }
        
        if forceDismiss ?? false{
            self.view.isUserInteractionEnabled = true
            let tapContainerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
            self.view.addGestureRecognizer(tapContainerGestureRecognizer)
        }
    }
    
    @objc func backViewTapped() {
        dismiss(animated: true)
    }
    
    func isValidURL(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return url.scheme != nil && url.host != nil
        }
        return false
    }
}
