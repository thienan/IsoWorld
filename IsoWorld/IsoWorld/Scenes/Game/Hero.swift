//
//  Hero.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/22/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import SpriteKit

struct HeroConstants {
  static let heroTexture = "human1"
  static let name = "hero"
  static let heroZPosition: CGFloat = 100
}

class Hero {
  private var hero: SKSpriteNode?

  lazy var walkAction: SKAction = {
    var textures: [SKTexture] = []
    for i in 0...1 {
      let texture = SKTexture(imageNamed: "human\(i + 1).png")
      textures.append(texture)
    }

    let action = SKAction.animateWithTextures(textures, timePerFrame: 0.15, resize: true, restore: true)

    return SKAction.repeatActionForever(action)
  }()

  func getHeroNode(
    nextLeftStartX nextLeftStartX: CGFloat,
                   islandHeight: CGFloat
    ) -> SKSpriteNode {
    hero = SKSpriteNode(imageNamed: HeroConstants.heroTexture)
    hero!.name = HeroConstants.name
    hero!.zPosition = HeroConstants.heroZPosition
    hero!.position = calculateHeroPosition(
      islandHeight: islandHeight,
      nextLeftStartX: nextLeftStartX,
      heroNodeWidth: self.hero!.size.width,
      heroNodeHeight: self.hero!.size.height
    )
    hero!.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(16, 18))
    hero!.physicsBody?.affectedByGravity = false
    hero!.physicsBody?.allowsRotation = false

    return hero!
  }

  private func calculateHeroPosition(
    islandHeight islandHeight: CGFloat,
    nextLeftStartX: CGFloat,
    heroNodeWidth: CGFloat,
    heroNodeHeight: CGFloat
    ) -> CGPoint {

    let xPosition = (-DefinedScreenWidth / 2)
      + nextLeftStartX
      - (heroNodeWidth / 2)
      - 20

    let yPosition = (-DefinedScreenHeight / 2)
      + islandHeight
      + heroNodeHeight / 2
      - 4
    return CGPoint(x: xPosition, y: yPosition)
  }

  

  func getHeroNodeFromParent() -> SKSpriteNode {
    return self.hero!
  }

}
