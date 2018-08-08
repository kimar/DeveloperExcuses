//
//  AppDelegate.swift
//  DeveloperExcusesDebug
//
//  Created by Marcus Kida on 08.06.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var screenSaverView = DeveloperExcusesView(frame: .zero, isPreview: false)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard
            let window = NSApplication.shared.mainWindow,
            let screenSaverView = screenSaverView
        else {
            preconditionFailure()
        }
        screenSaverView.textColor = .red
        screenSaverView.backgroundColor = .blue
        
        screenSaverView.frame = window.contentView!.bounds;
        screenSaverView.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(screenSaverView);
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

