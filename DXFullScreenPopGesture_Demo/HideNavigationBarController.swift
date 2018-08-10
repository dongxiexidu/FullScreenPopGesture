//
//  HideNavigationBarController.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/9.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class HideNavigationBarController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dx_navigationBarHidden = true
        self.view.backgroundColor = UIColor.blue
        
        do{
            let btn = UIButton.init()
            btn.addTarget(self, action: #selector(jumpVC), for: .touchUpInside)
            btn.frame = CGRect.init(x: 100, y: 100, width: 100, height: 40)
            view.addSubview(btn)
            btn.backgroundColor = UIColor.red
        }
        do{
            let btn = UIButton.init()
            btn.addTarget(self, action: #selector(jumpVC2), for: .touchUpInside)
            btn.frame = CGRect.init(x: 100, y: 200, width: 100, height: 40)
            view.addSubview(btn)
            btn.backgroundColor = UIColor.red
        }
    }

    @objc func jumpVC() {
        let vc = ShowNavigationBarController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func jumpVC2() {
        let vc = HideNavigationBar2Controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
}
