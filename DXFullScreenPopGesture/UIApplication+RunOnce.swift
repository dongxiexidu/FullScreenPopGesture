//
//  UIApplication+RunOnce.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

// MARK:- SelfAware 定义协议，使得程序在初始化的时候，将遵循该协议的类做了方法交换
protocol SelfAware: class {
    static func awake()
}

class NothingToSeeHere {
    static func harmlessFunction() {

        // 打印 11930 获取所有的类数量
        let typeCount = Int(objc_getClassList(nil, 0))
        
        // 在Swift中无类型的指针，原始内存可以用UnsafeRawPointer 和UnsafeMutableRawPointer来表示
        // 定义一个存放类的数组,capacity指定分配内存大小
        // 不提供自动内存管理，没有类型安全性
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        // 获取所有的类,存放到数组types
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        
        // 如果该类实现了SelfAware协议，那么调用awake方法
        for index in 0 ..< typeCount {
            (types[index] as? SelfAware.Type)?.awake()
        }
        //        types.deallocate(capacity: typeCount)
        // 释放
        types.deallocate()
    }
}


extension UIApplication {
    // 定义内联函数
    private static let runOnce: Void = {
        
        NothingToSeeHere.harmlessFunction()
    }()
    
    // 在applicationDidFinishLaunching方法之前调用
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}

