//
//  Tile.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/8/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation

enum Tile: Int {

  case Ground
  case Wall

  var description: String {
    switch self {
    case Ground:
      return "Ground"
    case Wall:
      return "Wall"
    }
  }

  var image: String {
    switch self {
    case Ground:
      return "iso_ground"
    case Wall:
      return "iso_wall"
    }
  }
}
