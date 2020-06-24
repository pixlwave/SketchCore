import SpriteKit

open class SketchScene: SKScene {
    
    public var sketchView: SketchView?
    public var showsPhysics = false
    public var ignoresSiblingOrder = true
    public var showsNodeCount = false
    public var showsDrawCount = false
    public var clearTexture = true
    public var exportPNG = false
    public var frameHandler: FrameHandler?
    
    var frameTimes = [TimeInterval](repeating: CACurrentMediaTime(), count: 16)
    public var frameRate: Double {
        let times = frameTimes      // copy as frameTimes is modified from another thread
        let count = times.count - 1
        let time = times[count] - times[0]
        return Double(count) / time
    }
    
    required public init?(coder decoder: NSCoder) { fatalError("Not available") }
    
    public override init() {
        super.init(size: Sketch.size)
        scaleMode = .aspectFill
    }
    
    override open var acceptsFirstResponder: Bool {
        return true
    }
    
    override open func becomeFirstResponder() -> Bool {
        return true
    }
    
    override open func resignFirstResponder() -> Bool {
        return false
    }
    
}
