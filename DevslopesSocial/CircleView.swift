//
//  CircleView.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/20/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.bounds.width / 2
    }
}
