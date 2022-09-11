//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

import CoreFoundation

struct Timer {
    private var startTime: CFAbsoluteTime?
    mutating func start() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    mutating func stop() -> CFAbsoluteTime {
        guard let startTime else {
            fatalError("Not started")
        }
        return CFAbsoluteTimeGetCurrent() - startTime
    }
}
