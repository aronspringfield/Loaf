//
//  Loaf.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-04.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

final public class Loaf {
    
    // MARK: - Specifiers
    
    /// Define a custom style for the loaf.
    public struct Style {
        /// Specifies the position of the icon on the loaf. (Default is `.left`)
        ///
        /// - left: The icon will be on the left of the text
        /// - right: The icon will be on the right of the text
        public enum IconAlignment {
            case natural
            case left
            case right
        }
        
        /// The background color of the loaf.
        let backgroundColor: UIColor
        
        /// The color of the label's text
        let textColor: UIColor
        
        /// The color of the icon (Assuming it's rendered as template)
        let tintColor: UIColor
        
        /// The font of the label
        let font: UIFont
        
        /// The icon on the loaf
        let icon: UIImage?
        
        let textAlignment: NSTextAlignment
        
        /// The position of the icon
        let iconAlignment: IconAlignment
        
        public init(backgroundColor: UIColor, textColor: UIColor = .white, tintColor: UIColor = .white, font: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium), icon: UIImage? = Icon.info, textAlignment: NSTextAlignment = .natural, iconAlignment: IconAlignment = .natural) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.tintColor = tintColor
            self.font = font
            self.icon = icon
            self.textAlignment = textAlignment
            self.iconAlignment = iconAlignment
        }
    }
    
    /// Defines the loaf's status. (Default is `.info`)
    ///
    /// - success: Represents a success message
    /// - error: Represents an error message
    /// - warning: Represents a warning message
    /// - info: Represents an info message
    /// - custom: Represents a custom loaf with a specified style.
    public enum State {
        case success
        case error
        case warning
        case info
        case custom(Style)
    }
    
    /// Defines the loaction to display the loaf. (Default is `.bottom`)
    ///
    /// - top: Top of the display
    /// - bottom: Bottom of the display
    public enum Location: Equatable {
        case top
        case bottom
        case custom(CGFloat)

        public static func ==(lhs: Location, rhs: Location) -> Bool {
            switch (lhs, rhs) {
            case (.top, .top),
                 (.bottom, .bottom):
                return true
            case let (.custom(a), .custom(b)):
                return a == b
            default:
                return false
            }
        }
    }
    
    /// Defines either the presenting or dismissing direction of loaf. (Default is `.vertical`)
    ///
    /// - left: To / from the left
    /// - right: To / from the right
    /// - vertical: To / from the top or bottom (depending on the location of the loaf)
    public enum Direction {
        case left
        case right
        case vertical
        case `static`
    }
    
    /// Icons used in basic states
    public enum Icon {
        public static let success = Icons.imageOfSuccess().withRenderingMode(.alwaysTemplate)
        public static let error = Icons.imageOfError().withRenderingMode(.alwaysTemplate)
        public static let warning = Icons.imageOfWarning().withRenderingMode(.alwaysTemplate)
        public static let info = Icons.imageOfInfo().withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: - Properties
    var message: String
    var state: State
    var location: Location
    var duration: TimeInterval
    var presentingDirection: Direction
    var dismissingDirection: Direction
    var completionHandler: ((Bool) -> Void)? = nil
    
    // MARK: - Public methods
    public init(_ message: String,
                duration: TimeInterval = 3,
                state: State = .info,
                location: Location = .bottom,
                presentingDirection: Direction = .vertical,
                dismissingDirection: Direction = .vertical,
                completionHandler: ((Bool) -> Void)? = nil) {
        self.message = message
        self.duration = duration
        self.state = state
        self.location = location
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
        self.completionHandler = completionHandler
    }

    public static func show(_ message: String,
                     duration: TimeInterval = 3,
                     state: State = .info,
                     location: Location = .bottom,
                     presentingDirection: Direction = .vertical,
                     dismissingDirection: Direction = .vertical,
                     completionHandler: ((Bool) -> Void)? = nil) {
        let loaf = Loaf(message, duration: duration,
                        state: state,
                        location: location,
                        presentingDirection: presentingDirection,
                        dismissingDirection: dismissingDirection,
                        completionHandler: completionHandler)
        let loafView = LoafView(loaf)
        Animator.shared.present(loafView: loafView)
    }
}

final class LoafView: UIView {
    var loaf: Loaf

    let label = UILabel()
    let imageView = UIImageView(image: nil)
    var font = UIFont.systemFont(ofSize: 14, weight: .medium)
    var textAlignment: NSTextAlignment = .natural

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(_ toast: Loaf) {
        self.loaf = toast
        let height = max(toast.message.heightWithConstrainedWidth(width: 240, font: font) + 12, 40)
        let contentSize = CGSize(width: 280, height: height)

        super.init(frame: CGRect(origin: .zero, size: contentSize))
        
        if case let Loaf.State.custom(style) = loaf.state {
            self.font = style.font
            self.textAlignment = style.textAlignment
        }

        clipsToBounds = true
        layer.cornerRadius = 6
        
        label.text = loaf.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.font = font
        label.textAlignment = textAlignment
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        switch loaf.state {
        case .success:
            imageView.image = Loaf.Icon.success
            backgroundColor = UIColor(hexString: "#2ecc71")
            constrainWithIconAlignment(.natural)
        case .warning:
            imageView.image = Loaf.Icon.warning
            backgroundColor = UIColor(hexString: "##f1c40f")
            constrainWithIconAlignment(.natural)
        case .error:
            imageView.image = Loaf.Icon.error
            backgroundColor = UIColor(hexString: "##e74c3c")
            constrainWithIconAlignment(.natural)
        case .info:
            imageView.image = Loaf.Icon.info
            backgroundColor = UIColor(hexString: "##34495e")
            constrainWithIconAlignment(.natural)
        case .custom(style: let style):
            imageView.image = style.icon
            backgroundColor = style.backgroundColor
            imageView.tintColor = style.tintColor
            label.textColor = style.textColor
            label.font = style.font
            constrainWithIconAlignment(style.iconAlignment, showsIcon: imageView.image != nil)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        Animator.shared.dismiss(loafView: self)
    }
    
    private func constrainWithIconAlignment(_ alignment: Loaf.Style.IconAlignment, showsIcon: Bool = true) {
        addSubview(label)
        
        if showsIcon {
            addSubview(imageView)

            let finalAlignment: Loaf.Style.IconAlignment
            switch alignment {
            case .left, .right:
                finalAlignment = alignment
            case .natural:
                let isRtl = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
                if isRtl {
                    finalAlignment = .right
                } else {
                    finalAlignment = .left
                }
            }
            
            switch finalAlignment {
            case .left:
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 28),
                    imageView.widthAnchor.constraint(equalToConstant: 28),
                    
                    label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
                    label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                    label.topAnchor.constraint(equalTo: topAnchor),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                    imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 28),
                    imageView.widthAnchor.constraint(equalToConstant: 28),
                    
                    label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                    label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -4),
                    label.topAnchor.constraint(equalTo: topAnchor),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            default:
                break
            }
        } else {
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}
