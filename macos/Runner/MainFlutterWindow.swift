import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame

    // macOS penceresinin mobil görünümden (390 x 680) daha küçük küçültülmesini
    // engelleyerek RenderFlex overflow hatalarını kesin olarak önler.
    let minWidth: CGFloat = 390
    let minHeight: CGFloat = 680

    if windowFrame.size.width < minWidth {
      windowFrame.size.width = minWidth
    }
    if windowFrame.size.height < minHeight {
      windowFrame.size.height = 750
    }

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.minSize = NSSize(width: minWidth, height: minHeight)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
