//
//  NibBackView.swift
//

import UIKit

class NibBackView: UIView {

    @IBOutlet var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViewFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViewFromNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpViewFromNibIfNeeded()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpViewFromNibIfNeeded()
    }

    func constrainContainerView() {
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    var nibName: String {
        return type(of: self).description().components(separatedBy: ".").last!
    }

    func didInstantiateBackingNib() {
        // No-op, subclasses may override.
    }

    private func setUpViewFromNibIfNeeded() {
        guard contentView == nil else {
            return
        }
        setUpViewFromNib()
    }

    private func setUpViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: nibName, bundle: bundle).instantiate(withOwner: self, options: nil)

        self.backgroundColor = .clear

        self.contentView.frame = self.bounds
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(self.contentView, at: 0)

        self.constrainContainerView()

        self.didInstantiateBackingNib()
    }

}
