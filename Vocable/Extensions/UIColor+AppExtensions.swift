import UIKit

extension UIColor {

    func darkenedForHighlight() -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        b *= 0.8
        return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
    }

    func blended(with otherColor: UIColor, amount: CGFloat) -> UIColor {

        let blendAmount = max(min(amount, 1.0), 0.0)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        otherColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let r = blendAmount * r1 + (1.0 - blendAmount) * r2
        let g = blendAmount * g1 + (1.0 - blendAmount) * g2
        let b = blendAmount * b1 + (1.0 - blendAmount) * b2
        let a = blendAmount * a1 + (1.0 - blendAmount) * a2

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    func disabled(blending otherColor: UIColor?) -> UIColor {
        guard let otherColor = otherColor else { return self }

        return blended(with: otherColor, amount: 0.6)
    }

    // MARK: New Branded Colors

    // TODO: Switch to compile-time generated symbols
    
    // Workaround for https://openradar.appspot.com/47113341. Prevent crashing the IBDesignables agent when using a color from the asset catalog.
    private convenience init?(safelyNamed name: String) {
        self.init(named: name,
                  in: Bundle(for: AppDelegate.self),
                  compatibleWith: nil)
    }

    static let primaryBackgroundColor = UIColor(safelyNamed: "Background")!

    static let defaultTextColor = UIColor(safelyNamed: "DefaultFontColor")!
    static var selectedTextColor: UIColor {
        return collectionViewBackgroundColor
    }

    static let highlightedTextColor = UIColor(safelyNamed: "TextHighlight")

    static let collectionViewBackgroundColor = UIColor(safelyNamed: "Background")!
    static let defaultCellBackgroundColor = UIColor(safelyNamed: "DefaultCellBackground")!
    static let categoryBackgroundColor = UIColor(safelyNamed: "CategoryBackground")!

    static let cellSelectionColor = UIColor(safelyNamed: "Selection")!
    static let cellBorderHighlightColor = UIColor(safelyNamed: "BorderHighlight")!
    static let alertBackgroundColor = UIColor(safelyNamed: "AlertBackground")!
    static let alertNormalText = UIColor(safelyNamed: "CategoryBackground")!

    // Dark Mode Colors
    static let darkModeBackgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    }

    static let darkModeTextColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    }

    static let darkModeSelectionColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.lightGray
    }

    static let darkModeCategoryBackgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.lightGray
    }

    static let darkModeBorderHighlightColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
    }

    static let darkModeAlertBackgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.lightGray
    }
}
