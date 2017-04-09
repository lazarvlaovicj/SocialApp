//
//  CircleView.swift
//  devslopes-social
//
//  Created by PRO on 3/17/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
