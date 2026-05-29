# MLCMSDK

MLCMSDK is a comprehensive Swift Package for iOS that enables developers to rapidly deploy rich interactive UI components. Whether you require a promotional video popup, a brief tutorial walkthrough or a floating web view MLCMSDK handles the presentation and logic.

## Features

* **Multi-format Support:** Displays images, GIFs and videos (AVPlayer integration).
* **Flexible Popups:** Bottom details sheets, centre information modals and full-page views.
* **Web Content:** Floating or full-screen WebViews with JavaScript interaction support.
* **Quick Tips:** Easily configurable onboarding or help walkthroughs.
* **SPM Ready:** Seamless integration via Swift Package Manager.

# MLCMSDK Integration and Usage Guide

The `MLCMSDK` is a powerful, highly flexible Swift Package Manager (SPM) framework designed to serve dynamic, campaign-driven content throughout the application. It supports bottom sheets, custom center popups, multi-slide walkthroughs, single image campaigns, and interactive floating HTML/web-views.

---

## 1. Architectural Overview

The SDK functions on a **Configurator-Presenter** layout:
- **`MLCMSDK` (Global Interface)**: The central entry point where application styling (fonts) is configured and dynamic view controllers are instantiated.
- **Dynamic Presenter Controllers**: Lightweight view controllers designed to overlay on any hosting `UIViewController` in fullscreen or bottom-sheet modalities.
- **Campaign Data Integration**: Seamlessly maps standard database/analytics payload models to custom interactive popups via keys defined in `MLCMKey` and module configurations in `MLCMPopupType`.

---

## 2. Git & Swift Package Manager (SPM) Installation

To integrate `MLCMSDK` into your host application or internal sub-modules:

### Option A: Via Xcode GUI (Recommended)
1. Open your project in Xcode.
2. Go to **File > Add Package Dependencies...** (or select the project node in the Project Navigator, select **Package Dependencies**, and click the `+` icon).
3. In the search box, paste the repository URL:
   ```text
   https://github.com/rajanpatel17/MLCMSDK.git
   ```
4. Define your dependency rules:
   - **Branch**: `main` (recommended for development) or select a specific tag / version range.
5. Choose the targets where you want to link the `MLCMSDK` framework.
6. Click **Add Package**.

### Option B: Programmatically via `Package.swift`
If your project is modularized using Swift Package Manager, add `MLCMSDK` directly to your manifest dependencies:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MyMainAppProject",
    dependencies: [
        .package(url: "https://github.com/rajanpatel17/MLCMSDK.git", branch: "main")
    ],
    targets: [
        .target(
            name: "YourFeatureSDKTarget",
            dependencies: [
                .product(name: "MLCMSDK", package: "MLCMSDK")
            ]
        )
    ]
)
```

---

## 3. Basic Setup & Initialization

Before triggering any dynamic popups, you must register the primary typography system with `MLCMSDK`. This ensures all dynamic campaign layouts align perfectly with your brand identity.

Import the module in your SDK manager or application bootstrap coordinator:

```swift
import MLCMSDK

// Initialize typography within your SDK setup manager (e.g., SDKManager.swift)
MLCMSDK.set(
    appFont: (
        regularFont: "inter-Regular", 
        semiBoldFont: "inter-SemiBold", 
        boldFont: "inter-Bold"
    )
)
```

---

## 4. API Reference and Usage Examples

`MLCMSDK` exposes dynamic view-generation helper functions matching specific campaign categories. All returned views are subclassed from standard `UIViewController` and are designed to be presented modally.

### A. Bottom Details Popup Sheet
A slide-up bottom sheet designed to show rich campaign imagery, custom-styled headings, sub-headings, and dual button layouts.

#### Method Definition
```swift
public class func getBottomDetailsPopupViewController(
    imageURL: String,
    imageCTA: String,
    text1: String,
    text1color: String,
    text2: String,
    text2color: String,
    btnCTAText1: String,
    btnCTAText2: String,
    btnBGColor1: String,
    btnBGColor2: String,
    contentType: String,
    forceDismiss: String,
    btnCTATextColor1: String,
    btnCTATextColor2: String,
    isCrossIcon: String,
    btn1CtaCompletion: @escaping () -> Void,
    btn2CtaCompletion: @escaping () -> Void,
    cancelCompletion: @escaping () -> Void,
    imageCompletion: @escaping () -> Void
) -> UIViewController
```

#### Usage Sample
```swift
import UIKit
import MLCMSDK

func displayBottomCampaign(on hostVC: UIViewController) {
    let bottomPopupVC = MLCMSDK.getBottomDetailsPopupViewController(
        imageURL: "https://example.com/assets/campaign_banner.png",
        imageCTA: "https://example.com/checkout/offers",
        text1: "Unlock Smart Settlement Benefits!",
        text1color: "#000000",
        text2: "Get 0% terminal settlement fees for the next 14 days by joining our program.",
        text2color: "#555555",
        btnCTAText1: "Skip",
        btnCTAText2: "Join Now",
        btnBGColor1: "#EBEBEB",
        btnBGColor2: "#0033A0",
        contentType: "bottomsheet",
        forceDismiss: "false",
        btnCTATextColor1: "#111111",
        btnCTATextColor2: "#FFFFFF",
        isCrossIcon: "true",
        btn1CtaCompletion: {
            print("Left Button (Skip) Tapped")
            // Handle secondary dismiss behavior
        },
        btn2CtaCompletion: {
            print("Right Button (Join Now) Tapped")
            // Execute primary registration / deep-link
        },
        cancelCompletion: {
            print("Popup Dismissed / Cross Icon Clicked")
        },
        imageCompletion: {
            print("Campaign Banner Image Tapped Directly")
            // Execute image-specific URL / deep-link action
        }
    )
    
    bottomPopupVC.modalPresentationStyle = .overFullScreen
    hostVC.present(bottomPopupVC, animated: true)
}
```

---

### B. Center Alert Popup
A standard, highly visible center modal popup. Ideal for high-priority notifications, system changes, or promotional alerts. Supports custom styles and optional button icon renders.

#### Method Definition
```swift
public class func getSingleCenterInfoViewController(
    imageURL: String,
    imageCTA: String,
    btnCTA1: String,
    btnCTA2: String,
    btnCTAText1: String,
    btnCTAText2: String,
    btnBGColor1: String,
    btnBGColor2: String,
    text1: String,
    text1Color: String,
    text2: String,
    text2color: String,
    contentType: String,
    isShowButtonIcons: Bool = false, // Renders action icons when true
    forceDismiss: String,
    btnCTATextColor1: String,
    btnCTATextColor2: String,
    isCrossIcon: String,
    btn1CtaCompletion: @escaping () -> Void,
    btn2CtaCompletion: @escaping () -> Void,
    imageCtaCompletion: @escaping () -> Void,
    cancelCompletion: @escaping () -> Void
) -> UIViewController
```

#### Usage Sample
```swift
func displayCenterPopupAlert(on hostVC: UIViewController) {
    let alertVC = MLCMSDK.getSingleCenterInfoViewController(
        imageURL: "https://example.com/assets/setup_alert.png",
        imageCTA: "mintoak://settings/settlement",
        btnCTA1: "Cancel",
        btnCTA2: "Proceed",
        btnCTAText1: "Back",
        btnCTAText2: "Verify Now",
        btnBGColor1: "#F5F5F5",
        btnBGColor2: "#1C3B57",
        text1: "Action Required: Complete Setup",
        text1Color: "#111111",
        text2: "Please verify your settlement banking credentials to prevent merchant payout delays.",
        text2color: "#666666",
        contentType: "popup",
        isShowButtonIcons: true,
        forceDismiss: "false",
        btnCTATextColor1: "#111111",
        btnCTATextColor2: "#FFFFFF",
        isCrossIcon: "true",
        btn1CtaCompletion: {
            print("Left Button (Back) Tapped")
        },
        btn2CtaCompletion: {
            print("Right Button (Verify Now) Tapped")
        },
        imageCtaCompletion: {
            print("Popup Main Graphic Clicked")
        },
        cancelCompletion: {
            print("Dismissed Alert")
        }
    )
    
    alertVC.modalPresentationStyle = .overFullScreen
    hostVC.present(alertVC, animated: true)
}
```

---

### C. Onboarding & Walkthrough (Quick Tips)
An elegant, paginated walkthrough view controller built from an array of tip descriptions. Seamlessly supports paginated indicators, slide transitions, customized header banners, and control buttons (Skip / Done / Cross).

#### Method Definition
```swift
public class func getQuickTipsViewController(
    list: [(text1: String, text1Color: String, text2: String, text2Color: String)],
    headertitletext: String,
    headerbgcolor: String,
    headerpagination: Bool,
    forceDismiss: String,
    btnCTA1: String,
    btnCTA2: String,
    btnCTAText1: String,
    btnCTAText2: String,
    btnCTATextColor1: String,
    btnCTATextColor2: String,
    cancelCompletion: @escaping () -> Void,
    doneButtonCompletion: @escaping () -> Void,
    skipButtonCompletion: @escaping () -> Void
) -> UIViewController
```

#### Usage Sample
```swift
func displayInteractiveTips(on hostVC: UIViewController) {
    // 1. Prepare paginated slides
    let slides = [
        (text1: "Step 1: Link your Terminal ID", text1Color: "#333333", text2: "Input your active terminal IDs inside the Profile module to link sales transactions.", text2Color: "#666666"),
        (text1: "Step 2: Track Real-Time Cashflow", text1Color: "#333333", text2: "Monitor instant settlements, percentage graphs, and statements from your unified dashboard.", text2Color: "#666666"),
        (text1: "Step 3: Setup Smart Notifications", text1Color: "#333333", text2: "Toggle push announcements to receive instant voice and alert updates for received payouts.", text2Color: "#666666")
    ]
    
    // 2. Instantiate and present Quick Tips
    let tipsVC = MLCMSDK.getQuickTipsViewController(
        list: slides,
        headertitletext: "Merchant Feature Walkthrough",
        headerbgcolor: "#E9F0FA",
        headerpagination: true,
        forceDismiss: "false",
        btnCTA1: "Skip",
        btnCTA2: "Next",
        btnCTAText1: "Skip",
        btnCTAText2: "Get Started",
        btnCTATextColor1: "#888888",
        btnCTATextColor2: "#0033A0",
        cancelCompletion: {
            print("Walkthrough closed using top cross button")
        },
        doneButtonCompletion: {
            print("Walkthrough completed (Get Started tapped)")
        },
        skipButtonCompletion: {
            print("Walkthrough skipped prematurely")
        }
    )
    
    tipsVC.modalPresentationStyle = .overFullScreen
    hostVC.present(tipsVC, animated: true)
}
```

---

### D. Single Image Popup
A clean, minimal campaign format consisting of a single graphic file overlay. Perfect for displaying quick advertisements, brand holiday greetings, or instant cash-back coupon visual triggers.

#### Method Definition
```swift
public class func getSingleImagePopupViewController(
    imageURL: String,
    imageCTA: String,
    contentType: String,
    forceDismiss: String,
    isCrossIcon: String,
    cancelCompletion: @escaping () -> Void,
    imageCompletion: @escaping () -> Void
) -> UIViewController
```

#### Usage Sample
```swift
func displayImageAdPopup(on hostVC: UIViewController) {
    let adPopupVC = MLCMSDK.getSingleImagePopupViewController(
        imageURL: "https://example.com/promos/festive_cashback.png",
        imageCTA: "mintoak://rewards/redeem?code=FESTIVE50",
        contentType: "popup3",
        forceDismiss: "false",
        isCrossIcon: "true",
        cancelCompletion: {
            print("Image campaign dismissed")
        },
        imageCompletion: {
            print("Promo banner clicked. Navigating user to rewards deep-link...")
        }
    )
    
    adPopupVC.modalPresentationStyle = .overFullScreen
    hostVC.present(adPopupVC, animated: true)
}
```

---

### E. Interactive Floating Web View / HTML Redirection
Instantiates a dynamic, animated sheet containing custom HTML content or rendering a remote URL. Extremely valuable for micro-frontends, feedback surveys, support chats, and real-time dashboard widgets.

#### Method Definition
```swift
public class func showFloatingWebView(
    vc: UIViewController,
    htmlContent: String,
    webURL: String,
    showFullScreen: Bool,
    ctaCompletion: @escaping (String) -> Void,
    eventCompletion: @escaping ([String: Any]) -> Void,
    dismissCompletion: @escaping () -> Void,
    expandCompletion: @escaping () -> Void
)
```

#### Usage Sample
```swift
func displayInteractiveMicrofrontend(on hostVC: UIViewController) {
    let surveyHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { font-family: -apple-system, sans-serif; padding: 20px; text-align: center; }
            h3 { color: #0033A0; }
            .option-btn { display: inline-block; background: #0033A0; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; margin-top: 15px; }
        </style>
    </head>
    <body>
        <h3>How would you rate your Settlement Experience?</h3>
        <p>Your feedback helps us tailor SmartHub Vyapar features to your growth.</p>
        <a class="option-btn" href="hdfc://feedback/submit?rating=5">⭐⭐⭐⭐⭐ Excellent</a>
    </body>
    </html>
    """

    MLCMSDK.showFloatingWebView(
        vc: hostVC,
        htmlContent: surveyHTML,
        webURL: "",
        showFullScreen: false, // Launches in bottom sheet format if false, full screen if true
        ctaCompletion: { redirectionURL in
            print("User performed custom action inside HTML frame: \(redirectionURL)")
            // Perform action, then dismiss manually
            MLCMSDK.closeFloatingView(vc: hostVC)
        },
        eventCompletion: { eventData in
            print("Received custom programmatic postMessage parameters: \(eventData)")
        },
        dismissCompletion: {
            print("HTML Modal collapsed or closed")
        },
        expandCompletion: {
            print("HTML Modal maximized to fullscreen")
        }
    )
}
```

---

### F. Programmatic Dismissals
You can close active MLCMSDK floating sheets or campaign wrappers manually at any time by calling:

```swift
// Dismisses active popup views currently layered on the host controller
MLCMSDK.closeFloatingView(vc: presentingViewController)
```

---

## 5. Enum & Constants Definitions

The SDK triggers dynamic layout changes based on specific campaign attributes received in your data configurations. Make sure to map keys from the database schema to the constants defined in your project:

### MLCM Key Map (`MLCMKey`)
These strings match attributes parsed from JSON dictionaries (e.g. `UserDefaults` list `mlcmObjectArrayList` or `mlcmBannerObjectArrayList`):
- `moduleType`: Type of campaign module (corresponds to `MLCMPopupType`).
- `text1` / `text1Color` / `text2` / `text2color`: Custom copy and color specs.
- `imageURL` / `imageCTA`: Imagery source URL and deep-link string payload.
- `btnCTA1` / `btnCTA2` / `btnCTAText1` / `btnCTAText2`: Core buttons and target links.
- `forceDismiss`: Prevents layout closing if set to `"true"` without performing CTA.
- `htmlId` / `htmlData` / `dynamicHtmlUrl`: Micro-frontend web parameters.

### Popup Types (`MLCMPopupType`)
Matches incoming dynamic campaign actions:
- `Bottom` (`"bottomsheet"`): Dynamic slide-up sheet.
- `Popup` (`"popup"`): Centered information view.
- `Walkthrough` (`"walkthrough"`): Paginated onboarding walkthrough.
- `popup2` (`"popup2"`): Customized centered information view.
- `popup3` (`"popup3"`): Image-only advertising layout.
- `HTMLRedirection` (`"htmlredirection"`): Fullscreen or floating micro-frontend layout.
- `FloatingView` (`"floatingview"`): Overlay bottom HTML view.

---

## 6. Troubleshooting

| Common Issue | Probable Cause | Action Item |
| :--- | :--- | :--- |
| **`No such module 'MLCMSDK'`** | Package link failure or build cache discrepancy. | Ensure `MLCMSDK` is declared under target's **Frameworks, Libraries, and Embedded Content** set to **Embed & Sign**. Run **Product > Clean Build Folder** (`Cmd+Shift+K`). |
| **Fonts do not render correctly inside popups** | Missing font registrations. | Ensure the font bundle strings (e.g., `"inter-Regular"`) exactly match custom post-processed assets included under `UIAppFonts` in host `Info.plist`. |
| **HTML banners are blank or do not load** | Missing secure SSL rules. | Ensure host `Info.plist` configures appropriate **App Transport Security Settings (ATS)** if you load assets/pages from external HTTP nodes. |
| **Dismiss actions do not respond** | Controller hierarchy mismatch. | Ensure the `vc` argument supplied to `closeFloatingView(vc:)` corresponds to the actual parent `UIViewController` displaying the campaign framework. |
