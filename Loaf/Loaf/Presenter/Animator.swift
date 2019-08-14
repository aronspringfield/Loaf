//
//  Animator.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-05.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

enum LoafAnimationState {
    case none
    case presenting
    case presented
    case dismissing
}

final class Animator: NSObject {
    
    static let shared = Animator()

    private lazy var window: Window = {
        let window = Window(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindow.Level.alert - 1

        let previousKeyWindow = UIApplication.shared.keyWindow
        window.makeKeyAndVisible()
        previousKeyWindow?.makeKey()
        return window
    }()

    private var animationState: LoafAnimationState = .none
    private(set) var queue = [LoafView]()
    var isPresenting: Bool {
        get {
            return window.subviews.count > 1
        }
    }

    func present(loafView: LoafView) {
        queue.insert(loafView, at: 0)
        presentNext()
    }

    func dismiss(loafView: LoafView) {
        animateOut(loafView: loafView)
    }

    private func presentNext() {
        guard animationState == .none else {
            return
        }
        guard queue.count > 0 else {
            return
        }

        if let loafView = queue.popLast() {
            animateIn(loafView: loafView)
        }
    }

    private func animateIn(loafView: LoafView) {
        guard animationState == .none else {
            return
        }
        animationState = .presenting

        window.addSubview(loafView)

        let superviewFrame = window.frame

        let xPos: CGFloat = (superviewFrame.size.width - loafView.frame.size.width) * 0.5
        let yPos: CGFloat

        switch loafView.loaf.location {
        case .bottom:
            yPos = superviewFrame.size.height - loafView.frame.size.height - 40
        case .top:
            yPos = 50
        case .custom(let yPoint):
            yPos = yPoint
        }

        let endingFrame: CGRect = CGRect(x: xPos, y: yPos, width: loafView.frame.width, height: loafView.frame.height)
        var startingFrame = endingFrame

        switch loafView.loaf.presentingDirection {
        case .left:
            startingFrame.origin.x -= superviewFrame.width
        case .right:
            startingFrame.origin.x += superviewFrame.width
        case .vertical:
            switch loafView.loaf.location {
            case .bottom:
                startingFrame.origin.y = superviewFrame.size.height
            case .top, .custom( _):
                startingFrame.origin.y = -loafView.frame.size.height
            }
        case .static:
            break
        }

        loafView.frame = startingFrame
        loafView.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.65, options: [], animations: {
            loafView.frame = endingFrame
            loafView.alpha = 1
        }, completion: { (finished) in
            DispatchQueue.main.asyncAfter(deadline: .now() + loafView.loaf.duration) {
                if self.animationState == .presenting {
                    self.animationState = .presented
                    self.animateOut(loafView: loafView)
                }
            }
        })
    }

    private func animateOut(loafView: LoafView) {
        guard animationState == .presented || animationState == .presenting else {
            return
        }
        guard loafView.superview != nil else {
            return
        }

        animationState = .dismissing

        let superviewFrame = window.frame
        var endingFrame = loafView.frame

        switch loafView.loaf.dismissingDirection {
        case .left:
            endingFrame.origin.x -= superviewFrame.width
        case .right:
            endingFrame.origin.x += superviewFrame.width
        case .vertical:
            switch loafView.loaf.location {
            case .bottom:
                endingFrame.origin.y = superviewFrame.size.height
            case .top, .custom( _):
                endingFrame.origin.y = -loafView.frame.size.height
            }
        case .static:
            break
        }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.65, options: [.beginFromCurrentState], animations: {
            loafView.frame = endingFrame
            loafView.alpha = 0
        }, completion: { finished in
            if loafView.superview != nil {
                loafView.loaf.completionHandler?(true)
                loafView.removeFromSuperview()
            }
            if self.animationState == .dismissing {
                self.animationState = .none
                self.presentNext()
            }
        })
    }
}
