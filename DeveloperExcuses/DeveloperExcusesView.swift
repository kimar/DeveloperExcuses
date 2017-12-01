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

private extension TimeInterval {
    static let minimumFetchInterval = 3.0
}

private extension Date {
    func isFetchDue(since: Date) -> Bool {
        return timeIntervalSinceReferenceDate > since.timeIntervalSinceReferenceDate + .minimumFetchInterval
    }
}

class DeveloperExcusesView: ScreenSaverView {
    let fetchQueue = DispatchQueue(label: "io.kida.DeveloperExcuses.fetchQueue")
    let mainQueue = DispatchQueue.main
    
    var label: NSTextField!
    var fetchingDue = true
    var lastFetchDate: Date?
    
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
    
    override var configureSheet: NSWindow? {
        return nil
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
    
    override func animateOneFrame() {
        fetchNext()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        var newFrame = label.frame
        newFrame.origin.x = 0
        newFrame.origin.y = rect.size.height / 2
        newFrame.size.width = rect.size.width
        newFrame.size.height = (label.stringValue as NSString).size(withAttributes: [NSAttributedStringKey.font: label.font!]).height
        label.frame = newFrame
        
        NSColor.black.setFill()
        rect.fill()
    }
    
    func initialize() {
        animationTimeInterval = 0.5
        addSubview(label)
        restoreLast()
        scheduleNext()
    }
    
    func restoreLast() {
        fetchingDue = true
        set(quote: UserDefaults.lastQuote)
    }
    
    func set(quote: String?) {
        if let q = quote {
            label.stringValue = q
            UserDefaults.lastQuote = q
            setNeedsDisplay(frame)
        }
    }
    
    func scheduleNext() {
        mainQueue.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let 🕑 = self?.lastFetchDate else {
                self?.scheduleForFetch()
                return
            }
            guard Date().isFetchDue(since: 🕑) else {
                self?.scheduleNext()
                return
            }
            self?.scheduleForFetch()
        }
    }
    
    private func scheduleForFetch() {
        fetchingDue = true
        fetchNext()
    }
    
    func fetchNext() {
        if !fetchingDue {
            return
        }
        fetchingDue = false
        fetchQueue.async { [weak self] in
            guard let data = try? Data(contentsOf: .websiteUrl), let string = String(data: data, encoding: .utf8) else {
                return
            }

            guard let regex = try? NSRegularExpression(pattern: .htmlRegex, options: NSRegularExpression.Options(rawValue: 0)) else {
                return
            }

            let quotes = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.lengthOfBytes(using: .utf8))).map { result in
                return (string as NSString).substring(with: result.range(at: 1))
            }
            
            self?.mainQueue.sync { [weak self] in
                self?.lastFetchDate = Date()
                self?.scheduleNext()
                self?.set(quote: quotes.first)
            }
        }
    }
}

private extension NSTextField {
    static func label(_ isPreview: Bool, bounds: CGRect) -> NSTextField {
        let label = NSTextField(frame: bounds)
        label.autoresizingMask = NSView.AutoresizingMask.width
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
