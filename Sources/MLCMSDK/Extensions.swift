//  Extensions.swift
//  MLCM

import Foundation
import UIKit

public protocol MLCMXIBed {
    static func instantiate() -> Self
}

public extension MLCMXIBed where Self: UIViewController {
    static func instantiate() -> Self {
        return Self(nibName: String(describing: self), bundle: .sdkBundle)
    }
}

extension Bundle {
    static var sdkBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: MLCMSDK.self)
        #endif
    }
}

extension UIFont {
    
    class func primeRegular(_ size: Int) -> UIFont {
        return UIFont(name: MLCMSDK.primeAppFont?.regularFont ?? "", size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size))
    }
    
    class func primeSemiBold(_ size: Int) -> UIFont {
        return UIFont(name: MLCMSDK.primeAppFont?.semiBoldFont ?? "", size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size))
    }
    
    class func primeBold(_ size: Int) -> UIFont {
        return UIFont(name: MLCMSDK.primeAppFont?.boldFont ?? "", size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size))
    }
}

@available(iOS 11.0, *)
public extension UIColor {
    class func hex(_ hex: String) -> UIColor {
        let r, g, b, a: CGFloat
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if !hex.contains("#") {
            hex.insert("#", at:  hex.startIndex)
        }
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            if hexColor.count == 8 {
                var chars = String(hexColor.filter { hexColor.contains($0) })
                let first_char = chars.removeFirst()
                let second_char = chars.removeFirst()
                chars.append(first_char)
                chars.append(second_char)
                hexColor = chars
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    return self.init(red: r, green: g, blue: b, alpha: a)
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255

                    return self.init(red: r, green: g, blue: b, alpha: 1.0)
                }
            } else {
                return .black
            }
        }

        print(#function)
//        fatalError("Invalid Hex String :- \(hex)")
        return .black
    }
}
