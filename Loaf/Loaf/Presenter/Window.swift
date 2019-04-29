//
//  Window.swift
//  LoafPlayground
//
//  Created by Aron Springfield on 26/04/2019.
//  Copyright © 2019 Palringo. All rights reserved.
//

import UIKit

class Window: UIWindow {

    let viewController: UIViewController

    override init(frame: CGRect) {
        viewController = UIViewController()
        super.init(frame: frame)
        viewController.view.frame = frame
        addSubview(viewController.view)
    }

    required init?(coder aDecoder: NSCoder) {
        viewController = UIViewController()
        super.init(coder: aDecoder)
        viewController.view.frame = frame
        addSubview(viewController.view)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = viewController.presentedViewController?.view else {
            return nil
        }

        let convertedPoint = self.convert(point, to: view)

        if view.bounds.contains(convertedPoint) {
            return view
        }

        return nil
    }
}
