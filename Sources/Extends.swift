import Cocoa
import SpriteKit

extension Date {
    func formatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        return dateFormatter.string(from: self)
    }
}

public extension NSImage {
    private static var colorArrayCache = [String: [NSColor]]()
    
    func colorArray(of length: Int = 200) -> [NSColor] {
        if let name = name(), let array = NSImage.colorArrayCache["\(name), \(length)"] {
            return array
        }
        
        var array = [NSColor]()
        guard let tiffRep = tiffRepresentation,
            let bitmapRep = NSBitmapImageRep(data: tiffRep)
            else { return array }
        
        for i in 0..<length {
            let x = i * bitmapRep.pixelsWide / length
            let y = bitmapRep.pixelsHigh / 2
            if let color = bitmapRep.colorAt(x: x, y: y), let deviceColor = color.usingColorSpace(.deviceRGB) {
                array.append(deviceColor)
            }
        }
        
        if let name = name() { NSImage.colorArrayCache["\(name), \(length)"] = array }
        
        return array
    }
}

public extension CGPath {
    func cgImage(strokeWidth: CGFloat, inverted: Bool) -> CGImage {
        let size = boundingBox.size
        let padding = 2 + strokeWidth
        let scale = CGAffineTransform(scaleX: (size.width - padding) / size.width, y: (size.height - padding) / size.height)
        var transform = scale.translatedBy(x: padding / 2, y: padding / 2)
        
        guard
            let deviceRGB = NSColorSpace.deviceRGB.cgColorSpace,
            let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: deviceRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
            let paddedPath = copy(using: &transform)
            else {
                fatalError("Core Graphics Error")
        }
        
        context.addPath(paddedPath)
        
        if inverted {
            context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
            context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        } else {
            context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            context.setStrokeColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        }
        
        if strokeWidth > 0 {
            context.setLineWidth(strokeWidth)
            context.drawPath(using: .fillStroke)
        } else {
            context.drawPath(using: .fill)
        }
        
        guard let image = context.makeImage() else { fatalError("Core Graphics Error") }
        return image
    }
}

public extension NSAttributedString {
    func cgImage() -> CGImage {
        let drawSize = size()
        
        guard
            let deviceRGB = NSColorSpace.deviceRGB.cgColorSpace,
            let context = CGContext(data: nil, width: Int(drawSize.width), height: Int(drawSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: deviceRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else {
                fatalError("Core Graphics Error")
        }
        
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        
        context.setTextDrawingMode(.fillStroke)
        draw(in: NSRect(origin: .zero, size: drawSize))
        
        guard let image = context.makeImage() else { fatalError("Core Graphics Error") }
        
        NSGraphicsContext.restoreGraphicsState()
        return image
    }
}

public extension SKShader {
    static var textureCrop = { () -> SKShader in
        guard
            let url = Bundle(for: Sketch.self).url(forResource: "TextureCrop", withExtension: "fsh"),
            let source = try? String(contentsOf: url)
            else {
                fatalError("Unable to load contents of TextureCrop.fsh")
        }
        
        let shader = SKShader(source: source)
        shader.attributes = [
            SKAttribute(name: "left", type: .float),
            SKAttribute(name: "right", type: .float),
            SKAttribute(name: "top", type: .float),
            SKAttribute(name: "bottom", type: .float)
        ]
        return shader
    }()
}

public extension SKTexture {
    // the size of the texture taking into account the sketch's scale factor
    func sceneSize() -> CGSize {
        return CGSize(width: size().width / Sketch.scaleFactor, height: size().height / Sketch.scaleFactor)
    }
}
