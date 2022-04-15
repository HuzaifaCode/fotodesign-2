//
//  KeyEventMonitor.swift
//  Logo Maker
//
//  Created by Imran on 30/11/2020.
//  Copyright © 2020 All rights reserved.
//

import Foundation
import Cocoa

public class KeyEventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> NSEvent?
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> NSEvent?) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
    }
    
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
