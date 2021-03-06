//
//  Stopwatch.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 03/06/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation

class Stopwatch {

  private var startTime: NSDate?

  var elapsedTime: NSTimeInterval {
    if let startTime = self.startTime {
      return (-startTime.timeIntervalSinceNow) / 60
    } else {
      return 0
    }
  }

  var elapsedTimeAsString: String {
    return String(format: "%02d:%02d.%d",
                  Int(elapsedTime / 60), Int(elapsedTime % 60), Int(elapsedTime * 10 % 10))
  }

  var isRunning: Bool {
    return startTime != nil
  }

  func start() {
    startTime = NSDate()
  }

  func stop() {
    startTime = nil
  }

}
