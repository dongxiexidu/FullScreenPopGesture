//
//  HideNavigationBar2Controller.swift
//  DXFullScreenPopGesture_Demo
//
//  Created by fashion on 2018/8/10.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class HideNavigationBar2Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dx_navigationBarHidden = true
        self.view.backgroundColor = UIColor.brown
        self.dx_allowPopDistance = 200
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
