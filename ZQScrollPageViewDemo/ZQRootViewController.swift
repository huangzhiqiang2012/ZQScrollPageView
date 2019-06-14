//
//  ZQRootViewController.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

class ZQRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionForNext(_ sender: Any) {
        navigationController?.pushViewController(ZQScrollPageController(), animated: true)
    }
}

