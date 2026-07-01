//  FlotingViewController.swift
//  MLCM

import Foundation
import UIKit
import AVKit
import AVFoundation

class FlotingViewController: NSObject {
    
    var superVC: UIViewController?
    var player: AVPlayer!
    var playerViewController = AVPlayerViewController()
    var playerRateObservation: NSKeyValueObservation?
    var floatingView: UIView!
    
    func startFloatingView(vc: UIViewController){
        superVC = vc
        let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        player = AVPlayer(url: videoURL)
        
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Prevents the video from taking over the screen when play is tapped
        playerViewController.entersFullScreenWhenPlaybackBegins = false
        // Adjusts the scaling (e.g., to maintain aspect ratio without stretching)
        playerViewController.videoGravity = .resizeAspect
        playerViewController.showsPlaybackControls = false
        
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
        playerViewController.view.removeFromSuperview()
        playerViewController.willMove(toParent: nil)
        playerViewController.removeFromParent()
    }
    
    @objc func maximizeFloatingView() {
        transitionToFullScreen()
    }
    
    func setFloatingView(){
        floatingView.removeFromSuperview()
        
        playerViewController.view.removeFromSuperview()
        playerViewController.willMove(toParent: nil)
        playerViewController.removeFromParent()
        
        playerViewController.view.frame = floatingView.bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController.showsPlaybackControls = false
        
        if let superVC = superVC {
            superVC.addChild(playerViewController)
            floatingView.addSubview(playerViewController.view)
            playerViewController.didMove(toParent: superVC)
        } else {
            floatingView.addSubview(playerViewController.view)
        }
        
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
        playerViewController.willMove(toParent: nil)
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
        
        // Prevents the video from taking over the screen when play is tapped
        playerViewController.entersFullScreenWhenPlaybackBegins = false
        // Adjusts the scaling (e.g., to maintain aspect ratio without stretching)
        playerViewController.videoGravity = .resizeAspect
        
        playerViewController.showsPlaybackControls = false
        playerViewController.allowsPictureInPicturePlayback = false
        playerViewController.exitsFullScreenWhenPlaybackEnds = false
        playerViewController.isModalInPresentation = true
        playerViewController.modalPresentationStyle = .fullScreen
        
        superVC?.present(playerViewController, animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let overlayView = self.playerViewController.contentOverlayView {
                overlayView.subviews.forEach { $0.removeFromSuperview() }
                
                let closeButton = UIButton(type: .system)
                closeButton.setTitle("Close", for: .normal)
                closeButton.setTitleColor(.white, for: .normal)
                closeButton.addTarget(self, action: #selector(self.dismissFullScreen), for: .touchUpInside)
                closeButton.translatesAutoresizingMaskIntoConstraints = false
                overlayView.addSubview(closeButton)
                
                let minimizeButton = UIButton(type: .system)
                minimizeButton.setTitle("Minimize", for: .normal)
                minimizeButton.setTitleColor(.white, for: .normal)
                minimizeButton.addTarget(self, action: #selector(self.minimizeToFloatingView), for: .touchUpInside)
                minimizeButton.translatesAutoresizingMaskIntoConstraints = false
                overlayView.addSubview(minimizeButton)
                
                NSLayoutConstraint.activate([
                    closeButton.leadingAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                    closeButton.topAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.topAnchor, constant: 20),
                    closeButton.widthAnchor.constraint(equalToConstant: 70),
                    closeButton.heightAnchor.constraint(equalToConstant: 44),
                    
                    minimizeButton.trailingAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                    minimizeButton.topAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.topAnchor, constant: 20),
                    minimizeButton.widthAnchor.constraint(equalToConstant: 90),
                    minimizeButton.heightAnchor.constraint(equalToConstant: 44)
                ])
            }
        }
    }
    
    @objc func dismissFullScreen() {
        floatingView.removeFromSuperview()
        superVC?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.playerViewController.willMove(toParent: nil)
            self.playerViewController.view.removeFromSuperview()
            self.playerViewController.removeFromParent()
        }
    }
    
    @objc func minimizeToFloatingView() {
        superVC?.dismiss(animated: true) { [weak self] in
            self?.setFloatingView()
        }
    }
    
}

