//
//  VocableListCellPrimaryButton.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/28/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

final class VocableListCellPrimaryButton: GazeableButton {

    private var trailingAccessoryViewLayoutGuide = UILayoutGuide()
    private(set) var trailingAccessoryView: UIView?

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addLayoutGuide(trailingAccessoryViewLayoutGuide)
        NSLayoutConstraint.activate([
            trailingAccessoryViewLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            trailingAccessoryViewLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingAccessoryViewLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            // 8 to match the minimum default content inset (until an independent UIControl subclass is authored)
            trailingAccessoryViewLayoutGuide.widthAnchor.constraint(equalToConstant: 8).withPriority(.defaultLow)
        ])
    }

    func setTrailingAccessory(_ accessory: VocableListCellAccessory?) {
        let trailingInsets: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        switch accessory?.content {
        case .image(let image):
            if let trailingImageView = trailingAccessoryView as? UIImageView {
                trailingImageView.image = image
            } else {
                setTrailingAccessoryView(UIImageView(image: image), insets: trailingInsets)
            }
        case .toggle(let isOn):
            if let trailingToggle = trailingAccessoryView as? UISwitch {
                trailingToggle.setOn(isOn, animated: true)
            } else {
                let toggle = UISwitch()
                toggle.setOn(isOn, animated: true)
                toggle.isUserInteractionEnabled = false
                setTrailingAccessoryView(toggle, insets: trailingInsets)
            }
        case .none:
            setTrailingAccessoryView(nil, insets: .zero)
        }
    }

    private func setTrailingAccessoryView(_ view: UIView?, insets: NSDirectionalEdgeInsets) {

        defer {
            trailingAccessoryView = view
        }

        if view === trailingAccessoryView {
            return
        }

        trailingAccessoryView?.removeFromSuperview()

        guard let view = view else {
            return
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: trailingAccessoryViewLayoutGuide.trailingAnchor, constant: -insets.trailing),
            view.centerYAnchor.constraint(equalTo: trailingAccessoryViewLayoutGuide.centerYAnchor),
            view.leadingAnchor.constraint(equalTo: trailingAccessoryViewLayoutGuide.leadingAnchor, constant: insets.leading)
        ])
    }

    override func layoutSubviews() {

        let layoutGuideWidth = trailingAccessoryViewLayoutGuide.layoutFrame.width

        if self.contentEdgeInsets.right != layoutGuideWidth {
            self.contentEdgeInsets.right = layoutGuideWidth
        }

        super.layoutSubviews()
    }
}
