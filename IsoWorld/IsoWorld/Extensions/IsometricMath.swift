//
//  IsometricMath.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/8/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation
import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return  CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGPoint) -> CGPoint {
  return  CGPoint(x: point.x * scalar.x, y: point.y * scalar.y)
}

func / (point: CGPoint, scalar: CGPoint) -> CGPoint {
  return  CGPoint(x: point.x / scalar.x, y: point.y / scalar.y)
}
