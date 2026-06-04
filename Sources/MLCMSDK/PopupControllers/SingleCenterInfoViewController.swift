//  SingleCenterInfoViewController.swift
//  MLCM

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class SingleCenterInfoViewController: UIViewController, MLCMXIBed {
    
    static func instantiate(imageURL: String, imageCTA: String, btnCTA1: String, btnCTA2: String, btnCTAText1: String, btnCTAText2: String, btnBGColor1: String, btnBGColor2: String, text1: String, text1Color: String, text2: String, text2color: String, contentType: String, isShowButtonIcons: Bool, forceDismiss: Bool, btnCTATextColor1: String, btnCTATextColor2: String, isCrossIcon: Bool) -> Self {
        let vc = Self.instantiate()
        vc.imageURL = imageURL
        vc.imageCTA = imageCTA
        vc.btnCTAText1 = btnCTAText1
        vc.btnCTAText2 = btnCTAText2
        vc.btnBGColor1 = btnBGColor1
        vc.btnBGColor2 = btnBGColor2
        vc.text1 = text1
        vc.text1Color = text1Color
        vc.text2 = text2
        vc.text2color = text2color
        vc.contentType = contentType
        vc.forceDismiss = forceDismiss
        vc.btnCTATextColor1 = btnCTATextColor1
        vc.btnCTATextColor2 = btnCTATextColor2
        vc.isShowButtonIcons = isShowButtonIcons
        vc.isCrossIcon = isCrossIcon
        return vc
    }
    var forceDismiss: Bool?
    var isCrossIcon: Bool?
    var isShowButtonIcons: Bool?
    var imageURL: String?
    var imageCTA: String?
    var btnCTAText1: String?
    var btnCTAText2: String?
    var btnBGColor1: String?
    var btnBGColor2: String?
    var text1: String?
    var text1Color: String?
    var text2: String?
    var text2color: String?
    var contentType: String?
    var btnCTATextColor1: String?
    var btnCTATextColor2: String?
    var player: AVPlayer!
    var playerViewController = AVPlayerViewController()
    
    var btn1CtaCompletion: (() -> ())? = nil
    var btn2CtaCompletion: (() -> ())? = nil
    var imageCtaCompletion: (() -> ())? = nil
    var cancelCompletion: (() -> ())? = nil

    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var LogoImageView: UIImageView!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var bottomButtonStackView: UIStackView!
    @IBOutlet weak var notIntrestButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var closeButtonContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func imageButtonAction(_ sender: UIButton) {
        if imageCTA != ""{
            if let nav = navigationController {
                imageCtaCompletion?()
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true) {
                    self.imageCtaCompletion?()
                }
            }
        }
    }
    
    @IBAction func notIntrestButtonAction(_ sender: UIButton) {
        if let nav = navigationController {
            btn1CtaCompletion?()
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true) {
                self.btn1CtaCompletion?()
            }
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
            self.cancelCompletion?()
        } else {
            dismiss(animated: true){
                self.cancelCompletion?()
            }
        }
    }
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        if let nav = navigationController {
            btn2CtaCompletion?()
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true) {
                self.btn2CtaCompletion?()
            }
        }
    }
    
}

extension SingleCenterInfoViewController{
    func setupUI(){
        topContainerView.layer.cornerRadius = 12
        LogoImageView.layer.cornerRadius = 8
        videoContainerView.layer.cornerRadius = 8
        titleLabel.font = UIFont.primeSemiBold(16)
        descLabel.font = UIFont.primeRegular(14)
        
        titleLabel.textColor = UIColor.hex(text1Color ?? "")
        descLabel.textColor = UIColor.hex(text2color ?? "")
        
        notIntrestButton.layer.cornerRadius = 8
        moreButton.layer.cornerRadius = 8
        
        notIntrestButton.setTitleColor(UIColor.hex(btnCTATextColor1 ?? ""), for: .normal)
        notIntrestButton.tintColor = UIColor.hex(btnCTATextColor1 ?? "")
        moreButton.setTitleColor(UIColor.hex(btnCTATextColor2 ?? ""), for: .normal)
        moreButton.tintColor = UIColor.hex(btnCTATextColor2 ?? "")
        notIntrestButton.backgroundColor = UIColor.hex(btnBGColor1 ?? "")
        moreButton.backgroundColor = UIColor.hex(btnBGColor2 ?? "")
        
        notIntrestButton.titleLabel?.font = UIFont.primeRegular(12)
        moreButton.titleLabel?.font = UIFont.primeRegular(12)
        
        if isShowButtonIcons ?? false{
            notIntrestButton.setImage(UIImage(named: ""), for: .normal)
            moreButton.setImage(UIImage(named: ""), for: .normal)
        }
        
        if forceDismiss ?? false{
            self.view.isUserInteractionEnabled = true
            let tapContainerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
            self.view.addGestureRecognizer(tapContainerGestureRecognizer)
        }
        
        setData()
    }
    
    @objc func backViewTapped() {
        dismiss(animated: true){
            self.cancelCompletion?()
        }
    }
    
    func setData(){
        
        if imageURL != ""{
            if contentType?.lowercased() == "video"{
                if let videoURL = URL(string: imageURL ?? "") {
                    videoContainerView.isHidden = false
                    imageButton.isHidden = true
                    LogoImageView.isHidden = true
                    playVideoFromURL(url: videoURL, view: videoContainerView)
                }
            }else if contentType?.lowercased() == "image" || contentType?.lowercased() == "gif"{
                videoContainerView.isHidden = true
                LogoImageView.isHidden = false
                imageButton.isHidden = false
                if contentType?.lowercased() == "gif"{
//                    UIImage.gifImageWithURL(imageURL ?? "") {  image in
//                        self.LogoImageView.image = image
//                    }
                    if let gifUrl = URL(string: self.imageURL ?? "") {
                        self.LogoImageView.sd_setImage(with: gifUrl) { (image, error, cacheType, imageURL) in
                            if let error = error {
                                print("Error loading image: \(error.localizedDescription)")
                            } else {
                                if let animatedImage = image {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        self.LogoImageView.image = animatedImage
                                    }
                                }
                            }
                        }
                    }
                }else{
                    if let imageURL = URL(string: imageURL ?? "") {
                        LogoImageView.sd_setImage(with: imageURL)
                    }
                }
            }else{
                videoContainerView.isHidden = true
                LogoImageView.isHidden = true
                imageButton.isHidden = true
            }
        }else{
            videoContainerView.isHidden = true
            LogoImageView.isHidden = true
            imageButton.isHidden = true
        }
        
        if text1 != "" || text2 != ""{
            
            if text1 != ""{
                titleLabel.text = text1 ?? ""
            }else{
                titleLabel.isHidden = true
            }
            
            if text2 != ""{
                descLabel.text = text2 ?? ""
            }else{
                descLabel.isHidden = true
            }
        }else{
            labelsStackView.isHidden = true
        }
        
        if btnCTAText1 != "" || btnCTAText2 != ""{
            
            closeButtonContainer.isHidden = (btnCTAText1 != "" && btnCTAText2 != "")
            
            if btnCTAText1 != ""{
                notIntrestButton.setTitle(btnCTAText1 ?? "", for: .normal)
            }else{
                notIntrestButton.isHidden = true
            }
            
            if btnCTAText2 != ""{
                moreButton.setTitle(btnCTAText2 ?? "", for: .normal)
            }else{
                moreButton.isHidden = true
            }
        }else{
            closeButtonContainer.isHidden = false
            bottomButtonStackView.isHidden = true
        }
        
        closeButtonContainer.isHidden = !(isCrossIcon ?? false)
    }
    
    func playVideoFromURL(url: URL, view: UIView) {
        player = AVPlayer(url: url)

        playerViewController.player = player
        playerViewController.view.frame.size.height = view.frame.size.height
        playerViewController.view.frame.size.width = view.frame.size.width
        view.addSubview(playerViewController.view)
        
        player.play()
    }
    
}
