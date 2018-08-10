//
//  UINavigationController+PopGesture.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import Foundation
import UIKit

// MARK:UINavigationController  交换pushViewController(_:animated:)方法
extension UINavigationController {
    static func classInitial() {
        swizzleMethod
    }
    
    private static let swizzleMethod: Void = {
        let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledSelector = #selector(dx_pushViewController)
        swizzlingForClass(UINavigationController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()
    
    @objc fileprivate func dx_pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard let contains = self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(self.dx_fullScreenPopGestureRecognizer!) else { return }
        
        if !contains {
            guard let dx_fullScreenPopGestureRecognizer = self.dx_fullScreenPopGestureRecognizer else { return }
            guard let systemGesture = interactivePopGestureRecognizer else { return  }
            guard let gestureView = systemGesture.view else { return  }
            gestureView.addGestureRecognizer(dx_fullScreenPopGestureRecognizer)
            let targets = systemGesture.value(forKey: "targets") as! [NSObject]
            guard let targetObj = targets.first else { return }
            guard let target = targetObj.value(forKey: "target") else { return }
            let action = Selector(("handleNavigationTransition:"))
            dx_fullScreenPopGestureRecognizer.delegate = self.dx_popGestureRecognizerDelegate
            dx_fullScreenPopGestureRecognizer.addTarget(target, action: action)
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        self.dx_setupVCNavigationBarAppearanceIfNeeded(appearingVC: viewController)
        if !(self.viewControllers.contains(viewController)) {
            self.dx_pushViewController(viewController, animated: animated)
        }
    }
    
    fileprivate func dx_setupVCNavigationBarAppearanceIfNeeded(appearingVC:UIViewController) {
        weak var weakSelf = self
        let block: DXVCWillAppearInjectBlock = {(_ vc: UIViewController?, _ animated: Bool) -> Void in
            let strongSelf = weakSelf
            if (strongSelf != nil) {
                strongSelf?.setNavigationBarHidden(vc?.dx_navigationBarHidden != nil, animated: animated)
            }
        }
        
        appearingVC.dx_willAppearInjectBlock = block
        guard let disAppearingVC = self.viewControllers.last else { return }
        if disAppearingVC.dx_willAppearInjectBlock == nil {
            disAppearingVC.dx_willAppearInjectBlock = block
        }
    }
    
    fileprivate var dx_popGestureRecognizerDelegate: DXFullScreenPopGestureRecognizerDelegate? {
        get {
            var delegate = objc_getAssociatedObject(self, RuntimeKey.dx_popGestureRecognizerDelegate!) as? DXFullScreenPopGestureRecognizerDelegate
            if delegate == nil {
                delegate = DXFullScreenPopGestureRecognizerDelegate()
                delegate?.navigationController = self
                objc_setAssociatedObject(self, RuntimeKey.dx_popGestureRecognizerDelegate!, delegate!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return delegate!
        }
    }
    
    fileprivate var dx_fullScreenPopGestureRecognizer : UIPanGestureRecognizer? {
        get {
            var pan = objc_getAssociatedObject(self, RuntimeKey.dx_fullScreenPopGestureRecognizer!) as? UIPanGestureRecognizer
            if pan == nil {
                pan = UIPanGestureRecognizer()
                pan!.maximumNumberOfTouches = 1
                objc_setAssociatedObject(self, RuntimeKey.dx_fullScreenPopGestureRecognizer!, pan!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return pan!
        }
    }
}
