//
//  KACircleCropViewController.swift
//  Circle Crop View Controller
//
//  Created by Keke Arif on 29/02/2016.
//  Copyright © 2016 Keke Arif. All rights reserved.
//

import UIKit

protocol KACircleCropViewControllerDelegate
{
    func circleCropDidCancel()
    func circleCropDidCropImage(_ image: UIImage)
}

class KACircleCropViewController: UIViewController, UIScrollViewDelegate {
    
    var delegate: KACircleCropViewControllerDelegate?
    
    var image: UIImage
    let imageView = UIImageView()
    let scrollView = KACircleCropScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 50))
    let cutterView = KACircleCropCutterView()
    
    let label = UILabel(frame: CGRect(x: 0, y: 10, width: 130, height: 30))
    let okButton = UIButton(frame: CGRect(x: 0, y: 10, width: 90, height: 30))
    let backButton = UIButton(frame: CGRect(x: 8, y: 10, width: 26, height: 26))
    
    
    init(withImage image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: View management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        scrollView.backgroundColor = UIColor.black
        
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = scaleWidth
        scrollView.maximumZoomScale = 4.0
//        if imageView.frame.size.width < scrollView.frame.size.width {
//            print("We have the case where the frame is too small")
//            scrollView.maximumZoomScale = scaleWidth * 2
//        } else {
//            scrollView.maximumZoomScale = 2.0
//        }
        scrollView.zoomScale = scaleWidth
        
        //Center vertically
        scrollView.contentOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.frame.size.height)/2)
        
        //Add in the black view. Note we make a square with some extra space +100 pts to fully cover the photo when rotated
        cutterView.frame = view.frame
        cutterView.frame.size.height += 100
        cutterView.frame.size.width = cutterView.frame.size.height
        
        //Add the label and buttons
        label.text = LocalizedLanguage(key: "lbl_title_adjust_crop", languageCode: lanCode)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = label.font.withSize(17)
        
        okButton.setTitle(LocalizedLanguage(key: "btn_done", languageCode: lanCode), for: UIControl.State())
        okButton.setTitleColor(UIColor.white, for: UIControl.State())
        okButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        okButton.addTarget(self, action: #selector(didTapOk), for: .touchUpInside)

        backButton.setImage(UIImage(named: "ic_back"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        setLabelAndButtonFrames()
        
        view.addSubview(scrollView)
        view.addSubview(cutterView)
        cutterView.addSubview(label)
        cutterView.addSubview(okButton)
        cutterView.addSubview(backButton)
    }
    
    
    func setLabelAndButtonFrames() {
        
        scrollView.center = view.center
        cutterView.center = view.center
        
        label.frame.origin = CGPoint(x: cutterView.frame.size.width/2 - label.frame.size.width/2, y: cutterView.frame.size.height/2 - view.frame.size.height/2 + 25)
        
        okButton.frame.origin = CGPoint(x: cutterView.frame.size.width/2 + view.frame.size.width/2 - okButton.frame.size.width - 12, y: cutterView.frame.size.height/2 - view.frame.size.height/2 + 25)
        
        backButton.frame.origin = CGPoint(x: cutterView.frame.size.width/2 - view.frame.size.width/2 + 3, y: cutterView.frame.size.height/2 - view.frame.size.height/2 + 25)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            self.setLabelAndButtonFrames()
            
            }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Button taps
    
    @objc func didTapOk() {

        let newSize = CGSize(width: image.size.width*scrollView.zoomScale, height: image.size.height*scrollView.zoomScale)
        
        let offset = scrollView.contentOffset
        
        switch UIDevice().type {
        case .iPhoneSE,.iPhone5,.iPhone5S, .iPhone5C:
             UIGraphicsBeginImageContextWithOptions(CGSize(width: 280, height: 280), false, 0)
        case .iPhone6, .iPhone6plus, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXS:
             UIGraphicsBeginImageContextWithOptions(CGSize(width: 324, height: 324), false, 0)
        default:
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 364, height: 364), false, 0)
        }
        
        var sharpRect = CGRect(x: -offset.x, y: -offset.y, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        
        image.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let imageData = finalImage!.pngData() {
            if let pngImage = UIImage(data: imageData) {
                delegate?.circleCropDidCropImage(pngImage)
            } else {
                delegate?.circleCropDidCancel()
            }
        } else {
            delegate?.circleCropDidCancel()
        }
    }
    
    @objc func didTapBack() {
        delegate?.circleCropDidCancel()
    }
    
}
