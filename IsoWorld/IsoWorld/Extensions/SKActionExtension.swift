//
//  SKActionExtension.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/22/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import UIKit
import SpriteKit

extension SKAction {

  class func moveDistance(distance: CGVector, fadeInWithDuration duration: NSTimeInterval) -> SKAction {
    let fadeIn = SKAction.fadeInWithDuration(duration)
    let moveIn = SKAction.moveBy(distance, duration: duration)
    return SKAction.group([fadeIn, moveIn])
  }

  class func moveDistance(distance: CGVector, fadeOutWithDuration duration: NSTimeInterval) -> SKAction {
    let fadeOut = SKAction.fadeOutWithDuration(duration)
    let moveOut = SKAction.moveBy(distance, duration: duration)
    return SKAction.group([fadeOut, moveOut])
  }

}
