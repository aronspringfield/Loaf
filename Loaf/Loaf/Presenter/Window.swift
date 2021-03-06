//
//  Window.swift
//  LoafPlayground
//
//  Created by Aron Springfield on 26/04/2019.
//  Copyright © 2019 Palringo. All rights reserved.
//

import UIKit

class Window: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rootViewController = UIViewController()
        self.rootViewController?.view.isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews {
            if let loafView = view as? LoafView {
                let convertedPoint = self.convert(point, to: loafView)

                if loafView.bounds.contains(convertedPoint) {
                    return loafView
                }
            }
        }

        return nil
    }
}
