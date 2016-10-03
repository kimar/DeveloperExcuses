import Foundation
import ScreenSaver

private extension String {
    static let lastQuote = "lastQuote"
    static let fetchQueue = "io.kida.DeveloperExcuses.fetchQueue"
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

private extension NSFont {
    func heightOfString (string: String, constrainedToWidth width: CGFloat) -> CGFloat {
        return NSString(string: string).boundingRect(
            with: CGSize(width: CGFloat(width), height: CGFloat(DBL_MAX)),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size.height
    }
}

class DeveloperExcusesView: ScreenSaverView {
    var label: NSTextField
    var fetchingDue = true
    
    override init?(frame: NSRect, isPreview: Bool) {
        label = .label(isPreview, bounds: frame)
        super.init(frame: frame, isPreview: isPreview)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func animateOneFrame() {
        fetchNext()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        var newFrame = label.frame
        let height = label.font!.heightOfString(string: label.stringValue, constrainedToWidth: rect.width)
        newFrame.size.height = height
        newFrame.origin.y = (NSHeight(bounds) - height) * 0.5
        label.frame = newFrame
        NSColor.white.setFill()
        NSRectFill(rect)
    }
    
    func initialize() {
        animationTimeInterval = 0.5
        addSubview(label)
        restoreLast()
        fetchNext()
    }
    
    func restoreLast() {
        fetchingDue = true
        set(quote: UserDefaults.lastQuote)
    }
    
    func set(quote: String?) {
        if let q = quote {
            label.stringValue = q
            UserDefaults.lastQuote = q
            fetchingDue = false
            setNeedsDisplay(frame)
        }
    }
    
    func scheduleNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.fetchingDue = true
        }
    }
    
    func fetchNext() {
        DispatchQueue.main.async { [weak self] in
            if let d = self?.fetchingDue, !d {
                return
            }
            self?.fetchingDue = false
        }
        
        DispatchQueue(label: .fetchQueue).async { [weak self] in
            guard let data = try? Data(contentsOf: .websiteUrl), let string = String(data: data, encoding: .utf8) else {
                return
            }
            
            guard let regex = try? NSRegularExpression(pattern: .htmlRegex, options: NSRegularExpression.Options(rawValue: 0)) else {
                return
            }
            
            let quotes = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.characters.count)).map { result in
                return (string as NSString).substring(with: result.rangeAt(1))
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.scheduleNext()
                self?.set(quote: quotes.first)
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
        label.textColor = .black
        label.font = NSFont(name: "Courier", size: (isPreview ? 12.0 : 24.0))
        label.backgroundColor = .clear
        label.isEditable = false
        label.isBezeled = false
        return label
    }
}
