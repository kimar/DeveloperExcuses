import Foundation
import ScreenSaver

private extension String {
    static let lastQuote = "lastQuote"
    static let htmlRegex = "<a href=\"/\" rel=\"nofollow\" style=\"text-decoration: none; color: #333;\">(.+)</a>"
}

private extension URL {
    static let websiteUrl = URL(string: "http://developerexcuses.com")!
}

private extension UserDefaults {

    static var lastQuote: String? {
        get {
            return UserDefaults.standard.string(forKey: .lastQuote)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .lastQuote)
            UserDefaults.standard.synchronize()
        }
    }
}


class DeveloperExcusesView: ScreenSaverView {
    let mainQueue = DispatchQueue.main
    
    var label: NSTextField!
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        label = .label(isPreview, bounds: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        label = .label(isPreview, bounds: bounds)
        initialize()
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func animateOneFrame() {
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        var newFrame = label.frame
        newFrame.origin.x = 0
        newFrame.origin.y = rect.size.height / 2
        newFrame.size.width = rect.size.width
        newFrame.size.height = (label.stringValue as NSString).size(withAttributes: [NSFontAttributeName: label.font!]).height
        label.frame = newFrame
        
        NSColor.black.setFill()
        NSRectFill(rect)
    }
    
    func initialize() {
        animationTimeInterval = 0.5
        addSubview(label)
        restoreLast()
        UserDefaults.standard.addObserver(self, forKeyPath: .lastQuote, options: NSKeyValueObservingOptions.new, context: nil)
        
        UserDefaultUpdater.sharedInstance.start()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: .lastQuote)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        mainQueue.async { [weak self] in
            self?.restoreLast()
        }
    }
    
    func restoreLast() {
        
        if let q = UserDefaults.lastQuote {
            label.stringValue = q
            setNeedsDisplay(frame)
        }
    }

}


class UserDefaultUpdater{
    static let sharedInstance = UserDefaultUpdater()
    
    let fetchQueue = DispatchQueue(label: "io.kida.DeveloperExcuses.fetchQueue")
    let mainQueue = DispatchQueue.main
    
    var started = false
    
    func start(){
        if (!started) {
            scheduleNext()
        }
        started = true;
    }
    
    func scheduleNext() {
        NSLog("scheduleNext")
        mainQueue.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.fetchNext()
        }
    }
    
    func fetchNext() {
        NSLog("fetchNext")
        fetchQueue.async { [weak self] in
            guard let data = try? Data(contentsOf: .websiteUrl), let string = String(data: data, encoding: .utf8) else {
                return
            }
            
            guard let regex = try? NSRegularExpression(pattern: .htmlRegex, options: NSRegularExpression.Options(rawValue: 0)) else {
                return
            }
            
            let quotes = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.characters.count)).map { result in
                return (string as NSString).substring(with: result.rangeAt(1))
            }
            
            self?.mainQueue.async { [weak self] in
                UserDefaults.lastQuote = quotes.first
                self?.scheduleNext()
            }
        }
    }
    
}

private extension NSTextField {
    static func label(_ isPreview: Bool, bounds: CGRect) -> NSTextField {
        let label = NSTextField(frame: bounds)
        label.autoresizingMask = .viewWidthSizable
        label.alignment = .center
        label.stringValue = "Loading…"
        label.textColor = .white
        label.font = NSFont(name: "Courier", size: (isPreview ? 12.0 : 24.0))
        label.backgroundColor = .clear
        label.isEditable = false
        label.isBezeled = false
        return label
    }
}
