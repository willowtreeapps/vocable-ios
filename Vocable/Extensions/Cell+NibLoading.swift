import UIKit

protocol ReuseIdentifiable: AnyObject {
    static var reuseIdentifier: String { get }
}

protocol NibLoadable: ReuseIdentifiable {
    static var nib: UINib { get }
}

extension NibLoadable {
    static var cell: Self? {
        return UINib(nibName: Self.reuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil).first as? Self
    }
}

extension UICollectionReusableView: NibLoadable {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
    }
}

extension UITableViewHeaderFooterView: ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: NibLoadable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
    }
}

extension UITableView {
    func registerClass<T: ReuseIdentifiable>(_ cellType: T.Type) {
        register(T.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func registerNib<T: NibLoadable>(cellType: T.Type) {
        register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueCell<T: ReuseIdentifiable>(cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as! T
    }
    
    func registerHeaderFooter<T: ReuseIdentifiable>(_ cellType: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueHeaderFooter<T: ReuseIdentifiable>(cellType: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: cellType.reuseIdentifier) as! T
    }
}

extension UICollectionView {
    
    func registerClass<T: ReuseIdentifiable>(_ cellType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func registerNib<T: NibLoadable>( _ cellType: T.Type) {
        register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueCell<T: ReuseIdentifiable>(type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }
    
    private func registerReusableNib<T: NibLoadable>(_ cellType: T.Type, kind: String) {
        register(cellType.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func registerNibHeader<T: NibLoadable>(_ cellType: T.Type) {
        registerReusableNib(T.self, kind: UICollectionView.elementKindSectionHeader)
    }
    
    func registerNibFooter<T: NibLoadable>(_ cellType: T.Type) {
        registerReusableNib(T.self, kind: UICollectionView.elementKindSectionFooter)
    }
    
    private func deququeReuseableCell<T: ReuseIdentifiable>(_ cellType: T.Type, kind: String, indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as! T
    }
    
    func dequeueHeader<T: ReuseIdentifiable>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        return deququeReuseableCell(T.self, kind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
    }
    
    func dequeueFooter<T: ReuseIdentifiable>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        return deququeReuseableCell(T.self, kind: UICollectionView.elementKindSectionFooter, indexPath: indexPath)
    }
}
