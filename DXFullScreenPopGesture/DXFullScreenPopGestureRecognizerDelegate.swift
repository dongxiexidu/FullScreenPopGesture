//
//  DXFullScreenPopGestureRecognizerDelegate.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXFullScreenPopGestureRecognizerDelegate:NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    // 与OC不同的是，这里不能直接把UIGestureRecognizerDelegate写成是UIPanGestureRecognizer的，必须得是UIGestureRecognizer。
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
       // let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        
        if (self.navigationController?.viewControllers.count)! <= 1 {
            return false
        }
        
        let topVC: UIViewController? = navigationController?.viewControllers.last
        if let disabled = topVC?.dx_popDisabled  {
            if disabled {
                return false
            }
        }
        
        let beginLocation: CGPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
        let allowedDistance: CGFloat? = topVC?.dx_allowPopDistance
        if (allowedDistance ?? 0.0) > 0 && beginLocation.x > (allowedDistance ?? 0.0) {
            return false
        }
        
        let isTransitioning = navigationController?.value(forKey: "_isTransitioning") as? Bool
        
        if let t = isTransitioning {
            if t {
                return false
            }
        }
        
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let isLeftToRight: Bool = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if (translation.x * multiplier) <= 0 {
            return false
        }
        
        return true
    }

}
