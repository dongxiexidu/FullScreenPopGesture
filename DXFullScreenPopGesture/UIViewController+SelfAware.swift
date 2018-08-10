//
//  UIViewController+SelfAware.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

// MARK:UIViewController  交换viewWillAppear(_:)与viewWillDisappear(_:)方法
extension UIViewController:SelfAware {
    static func awake() {
        UIViewController.classInit()
        UINavigationController.classInitial()
    }
    
    static func classInit() {
        swizzleMethod
    }
    
    @objc fileprivate func swizzled_viewWillAppear(_ animated: Bool) {
        swizzled_viewWillAppear(animated)
        if self.dx_willAppearInjectBlock != nil {
            self.dx_willAppearInjectBlock!(self,animated)
        }
    }
    
    @objc  func swizzled_viewWillDisAppear(_ animated: Bool) {
        swizzled_viewWillDisAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let viewcontroller = self.navigationController?.viewControllers.last
            if (viewcontroller != nil && viewcontroller?.dx_navigationBarHidden == nil) {
                self.navigationController?.setNavigationBarHidden(false, animated: false);
            }
        }
    }
    
    private static let swizzleMethod: Void = {
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(swizzled_viewWillAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
        
        let originalSelector1 = #selector(viewWillDisappear(_:))
        let swizzledSelector1 = #selector(swizzled_viewWillDisAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector1, swizzledSelector: swizzledSelector1)
    }()
    
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        guard (originalMethod != nil && swizzledMethod != nil) else {
            return
        }
        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}
