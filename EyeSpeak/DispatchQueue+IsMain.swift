import Foundation

internal extension DispatchQueue {

    private struct Storage {
        static let mainQueueKey = DispatchSpecificKey<Int>()
        static var didSetSpecificOnMainQueue = false
    }

    class var isMainQueue: Bool {
        if Storage.didSetSpecificOnMainQueue == false {
            DispatchQueue.main.setSpecific(key: Storage.mainQueueKey, value: 1)
            Storage.didSetSpecificOnMainQueue = true
        }
        let isMain = DispatchQueue.getSpecific(key: Storage.mainQueueKey) == 1
        return isMain
    }
}
