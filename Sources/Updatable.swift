import Foundation

public protocol Updatable {
    var isHidden: Bool { get set }
    func update(at time: TimeInterval)
}
