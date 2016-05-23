//
//  Island.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/23/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import SpriteKit

struct IslandConstants {
  static let name = "island"
  static let zPosition: CGFloat = 300.0
  static let height: CGFloat = 400.0
  static let maxWidth: CGFloat = 300.0
  static let minWidth: CGFloat = 100.0
  static let gapMinWidth: Int = 80
}

class Island {
  
  func loadIslands(animate: Bool, startLeftPoint: CGFloat, completition: () -> Void) -> (islandNode: SKSpriteNode, leftStartX: CGFloat) {
    let width = calculateWidth()
    let texture = SKTexture(imageNamed: "stone")
    let island = SKSpriteNode(texture: texture)
    island.size = CGSize(width: width, height: IslandConstants.height)
    island.zPosition = IslandConstants.zPosition
    island.name = IslandConstants.name
    if animate {
      island.position = CGPoint(
        x: DefinedScreenWidth / 2,
        y: -DefinedScreenHeight / 2 + IslandConstants.height / 2
      )
      island.runAction(
        SKAction.moveToX(
          -DefinedScreenWidth / 2 + width / 2 + startLeftPoint,
          duration: 0.3
        ),
        completion: completition
      )
    } else {
      island.position = CGPoint(
        x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint,
        y: -DefinedScreenHeight / 2 + IslandConstants.height / 2
      )
    }
    let leftStartX = width + startLeftPoint
    return (island, leftStartX)
  }

  private func calculateWidth() -> CGFloat {
    let max = Int(IslandConstants.maxWidth / 10)
    let min = Int(IslandConstants.minWidth / 10)
    return CGFloat(randomInRange(min...max) * 10)
  }

  func calculateGap(playAbleRectWidth: CGFloat, leftIslandWidth: CGFloat, nextLeftStartX: CGFloat) -> CGFloat {
    let maxGap = Int(
      playAbleRectWidth
        - IslandConstants.maxWidth
        - leftIslandWidth
    )
    let gap = CGFloat(
      randomInRange(
        IslandConstants.gapMinWidth...maxGap
      )
    )

    return nextLeftStartX + gap
  }

}
