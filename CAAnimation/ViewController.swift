//
//  ViewController.swift
//  CAAnimation
//
//  Created by 홍창남 on 2018. 7. 22..
//  Copyright © 2018년 홍창남. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var buttonView: PhotoButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonView.layer.cornerRadius = buttonView.frame.width / 2
    }

}

