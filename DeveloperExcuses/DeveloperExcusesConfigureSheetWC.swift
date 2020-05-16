import Cocoa
import ScreenSaver

class DeveloperExcusesConfigureSheetWC: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @IBAction func endSheet(_ sender: Any?) {
        if let window = window {
            window.sheetParent?.endSheet(window)
        }
    }
    
    @objc dynamic var fontSize: Double = UserDefaults.standard.double(forKey: .onelineFontSize) {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: .onelineFontSize)
        }
    }
}
