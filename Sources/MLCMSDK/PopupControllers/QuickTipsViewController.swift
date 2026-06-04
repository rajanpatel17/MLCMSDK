//  QuickTipsViewController.swift
//  MLCM

import UIKit

class QuickTipsViewController: UIViewController, MLCMXIBed {
    
    static func instantiate(list: [(text1: String, text1Color: String, text2: String, text2Color: String)], headertitletext: String, headerbgcolor: String, headerpagination: Bool, forceDismiss: Bool, btnCTAText1: String, btnCTAText2: String, btnCTATextColor1: String, btnCTATextColor2: String) -> Self {
        let vc = Self.instantiate()
        vc.list = list
        vc.headertitletext = headertitletext
        vc.headerbgcolor = headerbgcolor
        vc.headerpagination = headerpagination
        vc.forceDismiss = forceDismiss
        vc.btnCTAText1 = btnCTAText1
        vc.btnCTAText2 = btnCTAText2
        vc.btnCTATextColor1 = btnCTATextColor1
        vc.btnCTATextColor2 = btnCTATextColor2
        return vc
    }
    
    @IBOutlet weak var TopContainerView: UIView!
    @IBOutlet weak var countContainerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var closeButtonCompletion: (() -> ())? = nil
    var skipButtonCompletion: (() -> ())? = nil
    var doneButtonCompletion: (() -> ())? = nil
    var headertitletext: String?
    var headerbgcolor: String?
    var headerpagination: Bool?
    var forceDismiss: Bool?
    var btnCTAText1: String?
    var btnCTAText2: String?
    var btnCTATextColor1: String?
    var btnCTATextColor2: String?
    var list: [(text1: String, text1Color: String, text2: String, text2Color: String)] = []
    var counter = 0{
        didSet{
            countLabel.text = "\(headertitletext ?? "")" + ((headerpagination ?? false) ? " \(counter + 1)/\(list.count)" : "")
//            skipButton.setImage(UIImage(named: counter == 0 ? "" : "mlcmCalendar", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
            skipButton.setTitle((counter == 0 ? (btnCTAText1 ?? "") : ("Previous")).uppercased(), for: .normal)
            nextButton.setTitle((counter == (list.count - 1) ? (btnCTAText2 ?? "") : ("Next")).uppercased(), for: .normal)
            
            UIView.transition(with: titleLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.titleLabel.text = self?.list[self?.counter ?? 0].text1
                self?.titleLabel.textColor = UIColor.hex(self?.list[self?.counter ?? 0].text1Color ?? "")
                
            }, completion: nil)
            
            UIView.transition(with: descLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.descLabel.text = self?.list[self?.counter ?? 0].text2
                self?.descLabel.textColor = UIColor.hex(self?.list[self?.counter ?? 0].text2Color ?? "")
                
            }, completion: nil)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        if let nav = navigationController {
            closeButtonCompletion?()
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true) {
                self.closeButtonCompletion?()
            }
        }
    }
    
    @IBAction func backViewButtonAction(_ sender: UIButton) {
        if forceDismiss ?? false{
            dismiss(animated: true)
        }
    }
    @IBAction func skipButtonAction(_ sender: UIButton) {
        if counter > 0{
            counter -= 1
        }else if counter == 0{
            if let nav = navigationController {
                skipButtonCompletion?()
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true) {
                    self.skipButtonCompletion?()
                }
            }
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        if counter != (list.count - 1){
            counter += 1
        }else if counter == (list.count - 1){
            if let nav = navigationController {
                doneButtonCompletion?()
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true) {
                    self.doneButtonCompletion?()
                }
            }
        }
    }
    
//    @IBAction func buttonTapAction(_ sender: UIButton) {
//        switch sender {
//        case skipButton:
//            if counter > 0{
//                counter -= 1
//            }else if counter == 0{
//                if let nav = navigationController {
//                    skipButtonCompletion?()
//                    nav.popViewController(animated: true)
//                } else {
//                    dismiss(animated: true) {
//                        self.skipButtonCompletion?()
//                    }
//                }
//            }
//            break
//            
//        case nextButton:
//            if counter != (list.count - 1){
//                counter += 1
//            }else if counter == (list.count - 1){
//                if let nav = navigationController {
//                    doneButtonCompletion?()
//                    nav.popViewController(animated: true)
//                } else {
//                    dismiss(animated: true) {
//                        self.doneButtonCompletion?()
//                    }
//                }
//            }
//            
//        default:
//            break
//        }
//        
//    }
    
    
    
}

extension QuickTipsViewController{
    func setupUI(){
        TopContainerView.layer.cornerRadius = 8
        countContainerView.layer.cornerRadius = 4
        
        countContainerView.backgroundColor = UIColor.hex(headerbgcolor ?? "")
        
        countLabel.font = UIFont.primeRegular(12)
        
        titleLabel.font = UIFont.primeBold(16)
        descLabel.font = UIFont.primeRegular(14)
        
        skipButton.titleLabel?.font = UIFont.primeBold(12)
        nextButton.titleLabel?.font = UIFont.primeBold(12)
        
        skipButton.setTitle(btnCTAText1 ?? "", for: .normal)
        nextButton.setTitle(btnCTAText2 ?? "", for: .normal)
        
        skipButton.setTitleColor(UIColor.hex(btnCTATextColor1 ?? ""), for: .normal)
        nextButton.setTitleColor(UIColor.hex(btnCTATextColor2 ?? ""), for: .normal)
        
//        if forceDismiss ?? false{
//            self.view.isUserInteractionEnabled = true
//            let tapContainerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
//            self.view.addGestureRecognizer(tapContainerGestureRecognizer)
//        }
        
        if list.count > 0{
            counter = 0
        }
    }
    
//    @objc func backViewTapped() {
//        dismiss(animated: true)
//    }
}
