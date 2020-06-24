import Cocoa

public class ColorFlow {
    
    private var gradients = [[NSColor]]()
    private var currentGradient = [NSColor]()
    
    public init(gradients: [[NSColor]]) {
        self.gradients = gradients
        if gradients.count > 1 { currentGradient = self.gradients.removeFirst() }
        NotificationCenter.default.addObserver(self, selector: #selector(randomGradient), name: .newColors, object: nil)
    }
    
    public subscript(location: Double) -> NSColor {
        let index = location * Double(currentGradient.count)
        return currentGradient[Int(index)]
    }
    
    @objc public func randomGradient() {
        guard gradients.count > 1 else { return }
        
        let newArray = gradients.remove(at: Int.random(in: 0..<gradients.count))
        gradients.append(currentGradient)
        currentGradient = newArray
    }
    
}

public extension Notification.Name {
    static let newColors = Notification.Name("NewColors")
}
