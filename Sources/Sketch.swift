import Cocoa

public class Sketch {
    public static var size = CGSize(width: 1920, height: 1080)
    public static var scaleFactor: CGFloat = 1
    public static var pixelWidth: Int { return Int(scaleFactor * size.width) }
    public static var pixelHeight: Int { return Int(scaleFactor * size.height) }
}
