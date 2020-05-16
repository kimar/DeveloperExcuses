//
//  OnelinerView.swift
//  OnelinerKit
//
//  Created by Marcus Kida on 17.12.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import ScreenSaver

open class OnelinerView: ScreenSaverView {
    private let fetchQueue = DispatchQueue(label: .fetchQueue)
    private let mainQueue = DispatchQueue.main
    
    private var label: NSTextField!
    private var fetchingDue = true
    private var lastFetchDate: Date?
    
    public var backgroundColor = NSColor.black
    public var textColor = NSColor.white
    
    convenience init() {
        self.init(frame: .zero, isPreview: false)
        label = makeLabel(false, bounds: frame)
        initialize()
    }
    
    override init!(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        label = makeLabel(isPreview, bounds: frame)
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        label = makeLabel(isPreview, bounds: bounds)
        initialize()
    }
    
    override open var configureSheet: NSWindow? {
        return nil
    }
    
    override open var hasConfigureSheet: Bool {
        return false
    }
    
    override open func animateOneFrame() {
        fetchNext()
    }
    
    override open func draw(_ rect: NSRect) {
        super.draw(rect)
        
        var newFrame = label.frame
        newFrame.origin.x = 0
        newFrame.origin.y = rect.size.height / 2
        newFrame.size.width = rect.size.width
        newFrame.size.height = (label.stringValue as NSString).size(withAttributes: [NSAttributedString.Key.font: label.font!]).height
        label.frame = newFrame
        label.textColor = textColor
        
        backgroundColor.setFill()
        rect.fill()
    }
    
    open func fetchOneline(_ completion: @escaping (String) -> Void) {
        preconditionFailure("`fetchOneline` must be overridden")
    }
    
    open var onelineFontSize: Double {
        let size = UserDefaults.standard.double(forKey: .onelineFontSize)
        if size == 0 {
            let defaultSize = 24.0
            UserDefaults.standard.set(defaultSize, forKey: .onelineFontSize)
            UserDefaults.standard.synchronize()
            return defaultSize
        } else {
            return size
        }
    }
    
    private func makeLabel(_ isPreview: Bool, bounds: CGRect) -> NSTextField {
        let fontSize = CGFloat(onelineFontSize)
        let label = NSTextField(frame: bounds)
        label.autoresizingMask = NSView.AutoresizingMask.width
        label.alignment = .center
        label.stringValue = "Loading…"
        label.textColor = .white
        
        if #available(OSX 10.15, *) {
            label.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)
        } else {
            label.font = NSFont(name: "Courier", size: fontSize)
        }
        
        label.backgroundColor = .clear
        label.isEditable = false
        label.isBezeled = false
        return label
    }
    
    private func initialize() {
        animationTimeInterval = 0.5
        addSubview(label)
        restoreLast()
        scheduleNext()
    }
    
    private func restoreLast() {
        fetchingDue = true
        set(oneliner: UserDefaults.lastOneline)
    }
    
    private func set(oneliner: String?) {
        if let oneliner = oneliner {
            label.stringValue = oneliner
            UserDefaults.lastOneline = oneliner
            setNeedsDisplay(frame)
        }
    }
    
    private func scheduleNext() {
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
    
    private func fetchNext() {
        if !fetchingDue {
            return
        }
        fetchingDue = false
        fetchQueue.sync { [weak self] in
            self?.fetchOneline { oneline in
                self?.mainQueue.async { [weak self] in
                    self?.lastFetchDate = Date()
                    self?.scheduleNext()
                    self?.set(oneliner: oneline)
                }
            }
        }
    }
}
