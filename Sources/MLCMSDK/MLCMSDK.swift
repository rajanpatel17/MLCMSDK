//  MLCMSDK.swift
//  MLCM

import Foundation
import UIKit

public class MLCMSDK {
    
    internal static let floatingView = FlotingViewController()
    internal static let floatingWebView = FloatingWebViewController()
    internal static var primeAppFont: (regularFont: String, semiBoldFont: String, boldFont: String)?
    
    ///set primary fonts
    public class func set(appFont: (regularFont: String, semiBoldFont: String, boldFont: String)) {
        MLCMSDK.primeAppFont = appFont
    }
    
    public class func getQuickTipsViewController(list: [(text1: String, text1Color: String, text2: String, text2Color: String)], headertitletext: String, headerbgcolor: String, headerpagination: Bool, forceDismiss: String, btnCTA1: String, btnCTA2: String, btnCTAText1: String, btnCTAText2: String, btnCTATextColor1: String, btnCTATextColor2: String, closeButtonCompletion: (@escaping (() -> Void)), doneButtonCompletion: (@escaping (() -> Void)), skipButtonCompletion: (@escaping (() -> Void))) -> UIViewController {
        let vc = QuickTipsViewController.instantiate(list: list, headertitletext: headertitletext, headerbgcolor: headerbgcolor, headerpagination: headerpagination, forceDismiss: forceDismiss.lowercased() == "true", btnCTAText1: btnCTAText1, btnCTAText2: btnCTAText2, btnCTATextColor1: btnCTATextColor1, btnCTATextColor2: btnCTATextColor2)
        vc.closeButtonCompletion = {
            closeButtonCompletion()
        }
        vc.skipButtonCompletion = {
            skipButtonCompletion()
        }
        vc.doneButtonCompletion = {
            doneButtonCompletion()
        }
        return vc
    }
    
    public class func getSingleCenterInfoViewController(imageURL: String, imageCTA: String, btnCTA1: String, btnCTA2: String, btnCTAText1: String, btnCTAText2: String, btnBGColor1: String, btnBGColor2: String, text1: String, text1Color:String, text2: String, text2color: String, contentType: String, isShowButtonIcons: Bool = false, forceDismiss: String, btnCTATextColor1: String, btnCTATextColor2: String, isCrossIcon: String, btn1CtaCompletion: (@escaping (() -> Void)), btn2CtaCompletion: (@escaping (() -> Void)), imageCtaCompletion: (@escaping (() -> Void)), cancelCompletion: (@escaping (() -> Void))) -> UIViewController {
        
        let vc = SingleCenterInfoViewController.instantiate(imageURL: imageURL, imageCTA: imageCTA, btnCTA1: btnCTA1, btnCTA2: btnCTA2, btnCTAText1: btnCTAText1, btnCTAText2: btnCTAText2, btnBGColor1: btnBGColor1, btnBGColor2: btnBGColor2, text1: text1, text1Color: text1Color, text2: text2, text2color: text2color, contentType: contentType, isShowButtonIcons: isShowButtonIcons, forceDismiss: forceDismiss.lowercased() == "true",btnCTATextColor1: btnCTATextColor1, btnCTATextColor2: btnCTATextColor2, isCrossIcon: isCrossIcon.lowercased() == "true")
        
        vc.btn1CtaCompletion = {
            btn1CtaCompletion()
        }
        vc.btn2CtaCompletion = {
            btn2CtaCompletion()
        }
        vc.imageCtaCompletion = {
            imageCtaCompletion()
        }
        
        vc.cancelCompletion = {
            cancelCompletion()
        }
        
        return vc
    }
    
    public class func getBottomDetailsPopupViewController(imageURL: String, imageCTA: String, text1: String, text1color: String, text2: String, text2color: String, btnCTAText1: String, btnCTAText2: String, btnBGColor1: String, btnBGColor2: String, contentType: String, forceDismiss: String, btnCTATextColor1: String, btnCTATextColor2: String, isCrossIcon: String, btn1CtaCompletion: (@escaping (() -> Void)), btn2CtaCompletion: (@escaping (() -> Void)), cancelCompletion: (@escaping (() -> Void)), imageCompletion: (@escaping (() -> Void))) -> UIViewController {
        
        let vc = BottomDetailsPopupViewController.instantiate(imageURL: imageURL, imageCTA: imageCTA, text1: text1, text1color: text1color, text2: text2, text2color: text2color, btnCTAText1: btnCTAText1, btnCTAText2: btnCTAText2, btnBGColor1: btnBGColor1, btnBGColor2: btnBGColor2, contentType: contentType, forceDismiss: forceDismiss.lowercased() == "true", btnCTATextColor1: btnCTATextColor1, btnCTATextColor2: btnCTATextColor2, isCrossIcon: true)
        
        vc.btn1CtaCompletion = {
            btn1CtaCompletion()
        }
        
        vc.btn2CtaCompletion = {
            btn2CtaCompletion()
        }
        
        vc.cancelCompletion = {
            cancelCompletion()
        }
        
        vc.imageCompletion = {
            imageCompletion()
        }
        
        return vc
    }
    
    public class func getSingleImagePopupViewController(imageURL: String, imageCTA: String, contentType: String, forceDismiss: String, cancelCompletion: (@escaping (() -> Void)), imageCompletion: (@escaping (() -> Void))) -> UIViewController {
        
        let vc = SingleImagePopupViewController.instantiate(imageURL: imageURL, imageCTA: imageCTA, contentType: contentType, forceDismiss: forceDismiss.lowercased() == "true")
        
        vc.cancelCompletion = {
            cancelCompletion()
        }
        
        vc.imageCompletion = {
            imageCompletion()
        }
        
        return vc
    }
    
    public class func getHtmlContentPopupViewController(htmlContent: String, contentType: String, forceDismiss: Bool, cancelCompletion: (@escaping (() -> Void)), webViewCompletion: (@escaping (() -> Void))) -> UIViewController{
        
        let vc = ShowHtmlContentViewController.instantiate(htmlContent: htmlContent, contentType: contentType, forceDismiss: forceDismiss)
        
        vc.cancelCompletion = {
            cancelCompletion()
        }
        
        vc.webViewCompletion = {
            webViewCompletion()
        }
        
        return vc
    }
    
    public class func showPip(vc: UIViewController){
        floatingView.startFloatingView(vc: vc)
    }
    
    public class func closeFloatingView(vc: UIViewController){
        floatingWebView.closeButtonTapped()
    }
    
    public class func showFloatingWebView(vc: UIViewController, htmlContent: String, webURL: String, showFullScreen: Bool, completion: @escaping ((String) -> ()), eventCompletion: @escaping (([String:Any]) -> ()), dismissCompletion: @escaping (() -> ()), expandCompletion: @escaping (() -> ())){
        if floatingWebView.vcHtmlContent != htmlContent && htmlContent != ""{
            floatingWebView.closeButtonTapped()
            floatingWebView.startFloatingView(vc: vc, htmlContent: htmlContent, webURL: "", showFullScreen: showFullScreen)
            floatingWebView.completion = { str in
                completion(str)
            }
            floatingWebView.eventCompletion = { obj in
                eventCompletion(obj.compactMapValues { $0 as? String })
            }
            floatingWebView.dismissCompletion = { dismissCompletion() }
            floatingWebView.expandCompletion = { expandCompletion() }
        }else if floatingWebView.vcWebURL != webURL && webURL != ""{
            floatingWebView.closeButtonTapped()
            floatingWebView.startFloatingView(vc: vc, htmlContent: "", webURL: webURL, showFullScreen: showFullScreen)
            floatingWebView.completion = { str in
                completion(str)
            }
            floatingWebView.eventCompletion = { obj in
                eventCompletion(obj)
            }
            floatingWebView.dismissCompletion = { dismissCompletion() }
            floatingWebView.expandCompletion = { expandCompletion() }
        }
    }
    
}

// for disable zoom in webview
import WebKit

func getZoomDisableScript() -> WKUserScript {
    let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
    return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
}
