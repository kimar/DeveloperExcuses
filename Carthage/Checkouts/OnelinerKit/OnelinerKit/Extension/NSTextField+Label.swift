//
//  NSTextField+Label.swift
//  OnelinerKit
//
//  Created by Marcus Kida on 17.12.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import Foundation

extension NSTextField {
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
