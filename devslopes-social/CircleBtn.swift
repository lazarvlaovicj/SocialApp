//
//  CircleBtn.swift
//  devslopes-social
//
//  Created by PRO on 3/19/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

class CircleBtn: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = self.frame.width / 2
    }

}
