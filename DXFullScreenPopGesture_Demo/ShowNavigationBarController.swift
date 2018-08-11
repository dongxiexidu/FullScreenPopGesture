//
//  ShowNavigationBarController.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ShowNavigationBarController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "显示导航栏"
        
        // 禁止全屏手势(包括边缘侧滑手势)
        self.dx_popDisabled = true
        self.view.backgroundColor = UIColor.gray
    }

}
