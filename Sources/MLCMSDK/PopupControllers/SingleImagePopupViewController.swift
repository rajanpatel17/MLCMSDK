//
//  SingleImagePopupViewController.swift
//  MLCM
//
//  Created by Sagar Upadhyay on 17/07/23.
//  Copyright © 2023 Chaitanya Soni. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class SingleImagePopupViewController: UIViewController, XIBed {
    
    static func instantiate(imageURL: String, imageCTA: String, contentType: String, forceDismiss: Bool, isCrossIcon: Bool) -> Self {
        let vc = Self.instantiate()
        vc.imageURL = imageURL
        vc.imageCTA = imageCTA
        vc.contentType = contentType
        vc.forceDismiss = forceDismiss
        vc.isCrossIcon = isCrossIcon
        return vc
    }
    
    var imageURL: String?
    var imageCTA: String?
    var contentType: String?
    var forceDismiss: Bool?
    var isCrossIcon: Bool?
    var player: AVPlayer!
    var playerViewController = AVPlayerViewController()
    var imageCompletion: (() -> ())? = nil
    var cancelCompletion: (() -> ())? = nil
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
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


extension SingleImagePopupViewController{
    func setupUI(){
        containerView.layer.cornerRadius = 20
        imageView.layer.cornerRadius = 20
        videoContainer.layer.cornerRadius = 20
        // imageView.moa.url = imageURL
        
        btnClose.isHidden = !(isCrossIcon ?? false)
        
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        if contentType?.lowercased() == "video"{
            if let videoURL = URL(string: imageURL ?? "") {
                videoContainer.isHidden = false
                imageView.isHidden = true
                playVideoFromURL(url: videoURL, view: videoContainer)
            }
        }else if contentType?.lowercased() == "image" || contentType?.lowercased() == "gif"{
            videoContainer.isHidden = true
            imageView.isHidden = false
            if contentType?.lowercased() == "gif"{
                // UIImage.gifImageWithURL(imageURL ?? "") {  image in
                // self.imageView.image = image
                // }
                DispatchQueue.main.async {
                    if let gifUrl = URL(string: self.imageURL ?? "") {
                        self.imageView.sd_setImage(with: gifUrl) { (image, error, cacheType, imageURL) in
                            if let error = error {
                                print("Error loading image: \(error.localizedDescription)")
                            } else {
                                if let animatedImage = image {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        self.imageView.image = animatedImage
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                if let imageURL = URL(string: imageURL ?? "") {
                    imageView.sd_setImage(with: imageURL)
                }
            }
        }
        
        if forceDismiss ?? false{
            self.view.isUserInteractionEnabled = true
            let tapContainerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
            self.view.addGestureRecognizer(tapContainerGestureRecognizer)
        }
    }
    
    @objc func imageTapped() {
        if imageCTA != ""{
            dismiss(animated: true){
                self.imageCompletion?()
            }
        }
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
