//
//  Window.swift
//  LoafPlayground
//
//  Created by Aron Springfield on 26/04/2019.
//  Copyright © 2019 Palringo. All rights reserved.
//

import UIKit

class Window: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews {
            let convertedPoint = self.convert(point, to: view)

            if view.bounds.contains(convertedPoint) {
                return view
            }
        }

        return nil
    }
}
