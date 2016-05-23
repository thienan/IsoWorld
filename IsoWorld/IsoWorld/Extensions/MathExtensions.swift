//
//  MathExtensions.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/23/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation

func randomInRange(range: Range<Int>) -> Int {
  let count = UInt32(range.endIndex - range.startIndex)
  return  Int(arc4random_uniform(count)) + range.startIndex
}
