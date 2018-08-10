//
//  UIViewController+Runtime.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//
import UIKit

typealias DXVCWillAppearInjectBlock = (_ vc: UIViewController?, _ animated: Bool) -> Void

/// 从指定地址创建一个新的原始指针，指定为位模式
/// Creates a new raw pointer from the given address, specified as a bit pattern
///
/// - Parameter bitPattern: A bit pattern to use for the address of the new
///   raw pointer. If `bitPattern` is zero, the result is `nil`.
//   public init?(bitPattern: Int)

extension  UIViewController {
    
    // MARK:- RuntimeKey   动态绑属性
    struct RuntimeKey {
        
        // 在Swift中无类型的指针，原始内存可以用UnsafeRawPointer 和UnsafeMutableRawPointer来表示
        // A raw pointer for accessing untyped data 用于访问非类型数据的原始指针
        // init(bitPattern:) 从指定地址创建一个新的原始指针，指定为位模式
        
        // 哈希: http://swifter.tips/hash/
        // 比如 Int 的 hashValue 就是它本身：
        // print("dx_popDisabled".hashValue) 402467026446327185
        static let dx_popDisabled = UnsafeRawPointer.init(bitPattern: "dx_popDisabled".hashValue)
        
        static let dx_navigationBarHidden = UnsafeRawPointer.init(bitPattern: "dx_navigationBarHidden".hashValue)
        static let dx_allowPopDistance = UnsafeRawPointer.init(bitPattern: "dx_allowPopDistance".hashValue)
        static let dx_fullScreenPopGestureRecognizer = UnsafeRawPointer.init(bitPattern: "dx_fullScreenPopGestureRecognizer".hashValue)
        static let dx_willAppearInjectBlock = UnsafeRawPointer.init(bitPattern: "dx_willAppearInjectBlock".hashValue)
        static let dx_popGestureRecognizerDelegate = UnsafeRawPointer.init(bitPattern: "dx_popGestureRecognizerDelegate".hashValue)
    }
    
    // MARK:- 是否开启侧滑，默认true
    public var dx_popDisabled: Bool? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_popDisabled!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_popDisabled!) as? Bool
        }
    }
    
    // MARK:- 是否隐藏导航栏，默认false
    public var dx_navigationBarHidden: Bool? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_navigationBarHidden!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_navigationBarHidden!) as? Bool
        }
    }
    
    // MARK:- 允许侧滑的手势范围。默认全屏
    public var dx_allowPopDistance: CGFloat? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_allowPopDistance!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_allowPopDistance!) as? CGFloat
        }
    }
    
    var dx_willAppearInjectBlock:DXVCWillAppearInjectBlock? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_willAppearInjectBlock!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_willAppearInjectBlock!) as? DXVCWillAppearInjectBlock
        }
    }
    
}
