//  FlotingViewController.swift
//  MLCM

import Foundation
import UIKit
import AVKit

class FlotingViewController{
    
    var superVC: UIViewController?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var playerRateObservation: NSKeyValueObservation?
    var floatingView: UIView!
    
    func startFloatingView(vc: UIViewController){
        superVC = vc
        let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        
        // Create a floating view to hold the player
        floatingView = UIView(frame: CGRect(x: 20, y: (superVC?.view.frame.maxY ?? 0) - 300, width: 150, height: 250))
        floatingView.clipsToBounds = true
        floatingView.layer.cornerRadius = 10
        floatingView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        setFloatingView()
        
        playerRateObservation = player.observe(\.rate, options: [.new, .old]) { player, change in
            if player.rate == 0 && player.error == nil {
                player.play()
            }
        }
        
    }
    
    @objc func closeFloatingView() {
        floatingView.removeFromSuperview()
    }
    
    @objc func maximizeFloatingView() {
        transitionToFullScreen()
    }
    
    func setFloatingView(){
        floatingView.removeFromSuperview()
        
        playerLayer.frame = floatingView.bounds
        playerLayer.frame.size.height = floatingView.frame.size.height
        playerLayer.frame.size.width = floatingView.frame.size.width
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.cornerRadius = 10
        floatingView.layer.addSublayer(playerLayer)
        
        
        let closeButton = UIButton(frame: CGRect(x: 5, y: 10, width: 50, height: 30))
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeFloatingView), for: .touchUpInside)
        closeButton.isUserInteractionEnabled = true
        floatingView.addSubview(closeButton)
        
        let maximizeButton = UIButton(frame: CGRect(x: 100, y: 10, width: 50, height: 30))
        maximizeButton.setTitle("Maximize", for: .normal)
        maximizeButton.addTarget(self, action: #selector(maximizeFloatingView), for: .touchUpInside)
        maximizeButton.isUserInteractionEnabled = true
        floatingView.addSubview(maximizeButton)
        
        superVC?.view.addSubview(floatingView)
        player.play()
    }
    
    func transitionToFullScreen() {
//        playerLayer.removeFromSuperlayer()
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.player?.play()
        playerViewController.videoGravity = .resizeAspectFill
        playerViewController.showsPlaybackControls = false
        playerViewController.allowsPictureInPicturePlayback = false
        playerViewController.exitsFullScreenWhenPlaybackEnds = false
        playerViewController.isModalInPresentation = true
        superVC?.present(playerViewController, animated: true) {
            let closeButton = UIButton(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
            closeButton.setTitle("Close", for: .normal)
            closeButton.addTarget(self, action: #selector(self.dismissFullScreen), for: .touchUpInside)
            playerViewController.view.addSubview(closeButton)
            
            let minimizeButton = UIButton(frame: CGRect(x: playerViewController.view.bounds.width - 70, y: 20, width: 50, height: 50))
            minimizeButton.setTitle("Minimize", for: .normal)
            minimizeButton.addTarget(self, action: #selector(self.minimizeToFloatingView), for: .touchUpInside)
            playerViewController.view.addSubview(minimizeButton)
        }
    }
    
    @objc func dismissFullScreen() {
        floatingView.removeFromSuperview()
        superVC?.dismiss(animated: true, completion: nil)
    }
    
    @objc func minimizeToFloatingView() {
        superVC?.dismiss(animated: true)
    }
    
}

