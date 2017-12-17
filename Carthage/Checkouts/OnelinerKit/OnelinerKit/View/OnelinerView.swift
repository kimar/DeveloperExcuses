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
    
    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        label = .label(isPreview, bounds: frame)
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        label = .label(isPreview, bounds: bounds)
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
        newFrame.size.height = (label.stringValue as NSString).size(withAttributes: [NSAttributedStringKey.font: label.font!]).height
        label.frame = newFrame
        
        NSColor.black.setFill()
        rect.fill()
    }
    
    open func fetchOneline(_ completion: (String) -> Void) {
        preconditionFailure("`fetchOneline` must be overridden")
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
