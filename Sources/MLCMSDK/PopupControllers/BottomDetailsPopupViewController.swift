//  BottomDetailsPopupViewController.swift
//  MLCM

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class BottomDetailsPopupViewController: UIViewController, XIBed {
    
    static func instantiate(imageURL: String, imageCTA: String, text1: String, text1color: String, text2: String, text2color: String, btnCTAText1: String, btnCTAText2: String, btnBGColor1: String, btnBGColor2: String, contentType: String, forceDismiss: Bool, btnCTATextColor1: String, btnCTATextColor2: String, isCrossIcon: Bool) -> Self {
        let vc = Self.instantiate()
        vc.imageURL = imageURL
        vc.imageCTA = imageCTA
        vc.text1color = text1color
        vc.text1 = text1
        vc.text2 = text2
        vc.text2color = text2color
        vc.btnCTAText1 = btnCTAText1
        vc.btnCTAText2 = btnCTAText2
        vc.btnBGColor1 = btnBGColor1
        vc.btnBGColor2 = btnBGColor2
        vc.btnCTATextColor1 = btnCTATextColor1
        vc.btnCTATextColor2 = btnCTATextColor2
        vc.contentType = contentType
        vc.forceDismiss = forceDismiss
        vc.isCrossIcon = isCrossIcon
        return vc
    }
    var forceDismiss: Bool?
    var isCrossIcon: Bool?
    var imageURL: String?
    var imageCTA: String?
    var text1: String?
    var text1color: String?
    var text2: String?
    var text2color: String?
    var btnCTAText1: String?
    var btnCTAText2: String?
    var btnCTATextColor1: String?
    var btnCTATextColor2: String?
    var btnBGColor1: String?
    var btnBGColor2: String?
    var contentType: String?
    var player: AVPlayer!
    var playerViewController = AVPlayerViewController()
    
    var imageCompletion: (() -> ())? = nil
    var btn1CtaCompletion: (() -> ())? = nil
    var btn2CtaCompletion: (() -> ())? = nil
    var cancelCompletion: (() -> ())? = nil

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closePopupButton: UIButton!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var bottomButtonStackView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func closePopupButtonAction(_ sender: Any) {
        dismiss(animated: true){
            self.cancelCompletion?()
        }
    }
    
    @IBAction func proceedButtonAction(_ sender: Any) {
        dismiss(animated: true){
            self.btn1CtaCompletion?()
        }
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        dismiss(animated: true){
            self.btn2CtaCompletion?()
        }
    }
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
        if imageCTA != ""{
            dismiss(animated: true){
                self.imageCompletion?()
            }
        }
    }
    
}

extension BottomDetailsPopupViewController{
    func setupUI(){
        containerView.layer.cornerRadius = 10
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = .init(width: 0.0, height: -5.0)
        containerView.layer.shadowColor = UIColor.black.cgColor
        
        proceedButton.layer.cornerRadius = 10
        proceedButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 10
        nextButton.clipsToBounds = true
        
        proceedButton.backgroundColor = UIColor.hex(btnBGColor1 ?? "")
        nextButton.backgroundColor = UIColor.hex(btnBGColor2 ?? "")
        proceedButton.setTitleColor(UIColor.hex(btnCTATextColor1 ?? ""), for: .normal)
        nextButton.setTitleColor(UIColor.hex(btnCTATextColor2 ?? ""), for: .normal)
        
        proceedButton.titleLabel?.font = UIFont.primeSemiBold(16)
        nextButton.titleLabel?.font = UIFont.primeSemiBold(16)
        
        titleLabel.font = UIFont.primeSemiBold(16)
        descLabel.font = UIFont.primeRegular(14)
        
        titleLabel.textColor = UIColor.hex(text1color ?? "")
        descLabel.textColor = UIColor.hex(text2color ?? "")
        
        setData()
    }
    
    func setData(){
        if forceDismiss ?? false{
            self.view.isUserInteractionEnabled = true
            let tapContainerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
            self.view.addGestureRecognizer(tapContainerGestureRecognizer)
        }
        
        if imageURL != ""{
            if contentType?.lowercased() == "video"{
                if let videoURL = URL(string: imageURL ?? "") {
                    videoContainerView.isHidden = false
                    playerContainerView.isHidden = false
                    imageButton.isHidden = true
                    titleImage.isHidden = true
                    textViewContainer.isHidden = true
                    playVideoFromURL(url: videoURL, view: playerContainerView)
                }
            }else if contentType?.lowercased() == "image" || contentType?.lowercased() == "gif"{
                videoContainerView.isHidden = true
                playerContainerView.isHidden = true
                titleImage.isHidden = false
                imageButton.isHidden = false
                textViewContainer.isHidden = false
                if contentType?.lowercased() == "gif"{
//                    UIImage.gifImageWithURL(imageURL ?? "") {  image in
//                        self.titleImage.image = image
//                    }DispatchQueue.main.async {
                    if let gifUrl = URL(string: self.imageURL ?? "") {
                        self.titleImage.sd_setImage(with: gifUrl) { (image, error, cacheType, imageURL) in
                            if let error = error {
                                print("Error loading image: \(error.localizedDescription)")
                            } else {
                                if let animatedImage = image {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        self.titleImage.image = animatedImage
                                    }
                                }
                            }
                        }
                    }
                }else{
                    if let imageURL = URL(string: imageURL ?? "") {
                        titleImage.sd_setImage(with: imageURL)
                    }
                }
            }else{
                playerContainerView.isHidden = true
                videoContainerView.isHidden = true
                titleImage.isHidden = true
                imageButton.isHidden = true
                textViewContainer.isHidden = true
            }
        }else{
            playerContainerView.isHidden = true
            videoContainerView.isHidden = true
            imageButton.isHidden = true
            textViewContainer.isHidden = true
            titleImage.isHidden = true
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
        } else if imageURL != "" {
            textViewContainer.isHidden = false
            titleLabel.isHidden = true
            descLabel.isHidden = true
        } else {
            textViewContainer.isHidden = true
        }
        
        if btnCTAText1 != "" || btnCTAText2 != ""{
            
            if btnCTAText1 != ""{
                proceedButton.setTitle(btnCTAText1 ?? "", for: .normal)
            }else{
                proceedButton.isHidden = true
            }
            
            if btnCTAText2 != ""{
                nextButton.setTitle(btnCTAText2 ?? "", for: .normal)
            }else{
                nextButton.isHidden = true
            }
        }else{
            bottomButtonStackView.isHidden = true
        }
        closePopupButton.isHidden = !(isCrossIcon ?? false)
    }
    
    @objc func backViewTapped() {
        dismiss(animated: true){
            self.cancelCompletion?()
        }
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
