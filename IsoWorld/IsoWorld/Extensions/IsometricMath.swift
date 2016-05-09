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

func point2DToIso(p: CGPoint, inverse: Bool) -> CGPoint {
  // invert y pre conversion
  var point = p * CGPoint(x: 1, y: -1)
  // convert using algorithm
  point =  CGPoint(x: (point.x - point.y), y: ((point.x + point.y) / 2))
  // invert y post conversion
  if !inverse {
    point = point * CGPoint(x: 1, y: -1)
  } else {
    point = point * CGPoint(x: 1, y: -1)
  }
  return point
}
