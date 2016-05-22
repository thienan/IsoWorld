//
//  Game.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/22/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import UIKit

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
  var musicPlayer: AVAudioPlayer!

//  MARK: Objects
  var heroObj =  Hero()

  var gameOver = false {
    willSet {
      if newValue {
        let gameOverLayer = childNodeWithName(GameSceneChildName.GameOverLayerName.rawValue) as SKNode?
        gameOverLayer?.runAction(SKAction.moveDistance(CGVectorMake(0, 100), fadeInWithDuration: 0.2))
      }

    }
  }

  let IslandHeight: CGFloat = 400.0
  let IslandMaxWidth: CGFloat = 300.0
  let IslandMinWidth: CGFloat = 100.0
  let gravity: CGFloat = -100.0
  let IslandGapMinWidth: Int = 80
  let HeroSpeed: CGFloat = 760

  var isBegin = false
  var isEnd = false
  var leftIsland: SKSpriteNode?
  var rightIsland: SKSpriteNode?

  var nextLeftStartX: CGFloat = 0
  var bridgeHeight: CGFloat = 0

  lazy var playAbleRect: CGRect = {

    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = self.size.height / maxAspectRatio
    let playableMargin = (self.size.width - maxAspectRatioWidth) / 2.0
    return CGRectMake(playableMargin, 0, maxAspectRatioWidth, self.size.height)
  }()

  lazy var walkAction: SKAction = {
    var textures: [SKTexture] = []
    for i in 0...1 {
      let texture = SKTexture(imageNamed: "human\(i + 1).png")
      textures.append(texture)
    }

    let action = SKAction.animateWithTextures(textures, timePerFrame: 0.15, resize: true, restore: true)

    return SKAction.repeatActionForever(action)
  }()

  // MARK: - override
  override init(size: CGSize) {
    super.init(size: size)
    anchorPoint = CGPointMake(0.5, 0.5)
    physicsWorld.contactDelegate = self

    musicPlayer = setupAudioPlayerWithFile("bg_country", type: "mp3")
    musicPlayer.numberOfLoops = -1
    musicPlayer.play()
  }

  func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer {
    let url = NSBundle.mainBundle().URLForResource(file as String, withExtension: type as String)
    var audioPlayer: AVAudioPlayer?

    do {
      try audioPlayer = AVAudioPlayer(contentsOfURL: url!)
    } catch {
      print("NO AUDIO PLAYER")
    }

    return audioPlayer!
  }

  override func didMoveToView(view: SKView) {
    start()
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard !gameOver else {
      let gameOverLayer = childNodeWithName(GameSceneChildName.GameOverLayerName.rawValue) as SKNode?

      let location = touches.first?.locationInNode(gameOverLayer!)
      let retry = gameOverLayer!.nodeAtPoint(location!)


      if retry.name == GameSceneChildName.RetryButtonName.rawValue {
        retry.runAction(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "button_retry_down"), resize: false), SKAction.waitForDuration(0.3)]), completion: {[unowned self] () -> Void in
          self.restart()
          })
      }
      return
    }

    if !isBegin && !isEnd {
      isBegin = true

      let bridge = loadBridge()
      let hero = heroObj.getHeroNodeFromParent()

      let action = SKAction.resizeToHeight(CGFloat(DefinedScreenHeight - IslandHeight), duration: 1.5)
      bridge.runAction(action, withKey: GameSceneActionKey.BridgeGrowAction.rawValue)

      let scaleAction = SKAction.sequence([SKAction.scaleYTo(0.9, duration: 0.05), SKAction.scaleYTo(1, duration: 0.05)])
      let loopAction = SKAction.group([SKAction.playSoundFileNamed(GameSceneEffectAudioName.BridgeGrowAudioName.rawValue, waitForCompletion: true)])
      bridge.runAction(SKAction.repeatActionForever(loopAction), withKey: GameSceneActionKey.BridgeGrowAudioAction.rawValue)
      hero.runAction(SKAction.repeatActionForever(scaleAction), withKey: GameSceneActionKey.HeroScaleAction.rawValue)

      return
    }

  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if isBegin && !isEnd {
      isEnd  = true

      let hero = heroObj.getHeroNodeFromParent()
      hero.removeActionForKey(GameSceneActionKey.HeroScaleAction.rawValue)
      hero.runAction(SKAction.scaleYTo(1, duration: 0.04))

      let bridge = childNodeWithName(GameSceneChildName.BridgeName.rawValue) as? SKSpriteNode
      bridge!.removeActionForKey(GameSceneActionKey.BridgeGrowAction.rawValue)
      bridge!.removeActionForKey(GameSceneActionKey.BridgeGrowAudioAction.rawValue)
      bridge!.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.BridgeGrowOverAudioName.rawValue, waitForCompletion: false))

      bridgeHeight = bridge!.size.height

      let action = SKAction.rotateToAngle(CGFloat(-M_PI / 2), duration: 0.4, shortestUnitArc: true)
      let playFall = SKAction.playSoundFileNamed(GameSceneEffectAudioName.BridgeFallAudioName.rawValue, waitForCompletion: false)

      bridge!.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), action, playFall]), completion: {[unowned self] () -> Void in
        self.heroGo(self.checkPass())
        })
    }
  }

  func start() {
    loadBackground()
    loadTip()
    loadGameOverLayer()

    leftIsland = loadIslands(false, startLeftPoint: playAbleRect.origin.x)
    loadHero()

    let maxGap = Int(playAbleRect.width - IslandMaxWidth - (leftIsland?.frame.size.width)!)
    let gap = CGFloat(randomInRange(IslandGapMinWidth...maxGap))
    rightIsland = loadIslands(false, startLeftPoint: nextLeftStartX + gap)

    gameOver = false
  }

  func restart() {
    isBegin = false
    isEnd = false
    nextLeftStartX = 0
    removeAllChildren()
    start()
  }

  private func checkPass() -> Bool {
    let bridge = childNodeWithName(GameSceneChildName.BridgeName.rawValue) as? SKSpriteNode

    let rightPoint = DefinedScreenWidth / 2 + bridge!.position.x + self.bridgeHeight

    guard rightPoint < self.nextLeftStartX else {
      return false
    }

    guard CGRectIntersectsRect((leftIsland?.frame)!, bridge!.frame)
      && CGRectIntersectsRect((rightIsland?.frame)!, bridge!.frame) else {
      return false
    }

    return true
  }

  private func heroGo(pass: Bool) {

    let hero = heroObj.getHeroNodeFromParent()

    guard pass else {
      let bridge = childNodeWithName(GameSceneChildName.BridgeName.rawValue) as? SKSpriteNode

      let dis: CGFloat = bridge!.position.x + self.bridgeHeight
      let disGap = nextLeftStartX - (DefinedScreenWidth / 2 - abs(hero.position.x)) - (rightIsland?.frame.size.width)! / 2

      let move = SKAction.moveToX(dis, duration: NSTimeInterval(abs(disGap / HeroSpeed)))

      hero.runAction(walkAction, withKey: GameSceneActionKey.WalkAction.rawValue)
      hero.runAction(move, completion: {[unowned self] () -> Void in
        bridge!.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.4))

        hero.physicsBody!.affectedByGravity = true
        hero.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.DeadAudioName.rawValue, waitForCompletion: false))
        hero.removeActionForKey(GameSceneActionKey.WalkAction.rawValue)
        self.runAction(SKAction.waitForDuration(0.5), completion: {[unowned self] () -> Void in
          self.gameOver = true
          })
        })

      return
    }

    let dis: CGFloat = -DefinedScreenWidth / 2 + nextLeftStartX - hero.size.width / 2 - 20
    let disGap = nextLeftStartX - (DefinedScreenWidth / 2 - abs(hero.position.x)) - (rightIsland?.frame.size.width)! / 2

    let move = SKAction.moveToX(dis, duration: NSTimeInterval(abs(disGap / HeroSpeed)))

    hero.runAction(walkAction, withKey: GameSceneActionKey.WalkAction.rawValue)
    hero.runAction(move) { [unowned self] () -> Void in

      hero.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.VictoryAudioName.rawValue, waitForCompletion: false))
      hero.removeActionForKey(GameSceneActionKey.WalkAction.rawValue)
      self.moveIslandAndCreateNew()
    }
  }

  private func moveIslandAndCreateNew() {
    let action = SKAction.moveBy(CGVectorMake(-nextLeftStartX + (rightIsland?.frame.size.width)! + playAbleRect.origin.x - 2, 0), duration: 0.3)
    rightIsland?.runAction(action)

    let hero = heroObj.getHeroNodeFromParent()
    let bridge = childNodeWithName(GameSceneChildName.BridgeName.rawValue) as? SKSpriteNode

    hero.runAction(action)
    bridge!.runAction(SKAction.group([SKAction.moveBy(CGVectorMake(-DefinedScreenWidth, 0), duration: 0.5), SKAction.fadeAlphaTo(0, duration: 0.3)])) { () -> Void in
      bridge!.removeFromParent()
    }

    leftIsland?.runAction(SKAction.moveBy(CGVectorMake(-DefinedScreenWidth, 0), duration: 0.5), completion: {[unowned self] () -> Void in
      self.leftIsland?.removeFromParent()

      let maxGap = Int(self.playAbleRect.width - (self.rightIsland?.frame.size.width)! - self.IslandMaxWidth)
      let gap = CGFloat(self.randomInRange(self.IslandGapMinWidth...maxGap))

      self.leftIsland = self.rightIsland
      self.rightIsland = self.loadIslands(true, startLeftPoint: self.playAbleRect.origin.x + (self.rightIsland?.frame.size.width)! + gap)
      })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - load node
private extension GameScene {

  func loadBackground() {

    guard let _ = childNodeWithName("background") as? SKSpriteNode else {
      let texture = SKTexture(image: UIImage(named: "background.png")!)
      let node = SKSpriteNode(texture: texture)
      node.size = texture.size()
      node.zPosition = GameSceneZposition.BackgroundZposition.rawValue
      self.physicsWorld.gravity = CGVectorMake(0, gravity)

      addChild(node)
      return
    }
  }

  func loadHero() {
    let hero = heroObj.getHeroNode(
      nextLeftStartX: self.nextLeftStartX,
      islandHeight: self.IslandHeight
    )
    addChild(hero)
  }

  func loadTip() {
    let tip = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    tip.name = GameSceneChildName.TipName.rawValue
    tip.text = ""
    tip.position = CGPointMake(0, DefinedScreenHeight / 2 - 350)
    tip.fontColor = SKColor.blackColor()
    tip.fontSize = 52
    tip.zPosition = GameSceneZposition.TipZposition.rawValue
    tip.horizontalAlignmentMode = .Center

    addChild(tip)
  }

  func loadPerfect() {

    defer {
      let perfect = childNodeWithName(GameSceneChildName.PerfectName.rawValue) as? SKLabelNode?
      let sequence = SKAction.sequence([SKAction.fadeAlphaTo(1, duration: 0.3), SKAction.fadeAlphaTo(0, duration: 0.3)])
      let scale = SKAction.sequence([SKAction.scaleTo(1.4, duration: 0.3), SKAction.scaleTo(1, duration: 0.3)])
      perfect!!.runAction(SKAction.group([sequence, scale]))
    }

    guard let _ = childNodeWithName(GameSceneChildName.PerfectName.rawValue) as? SKLabelNode? else {
      let perfect = SKLabelNode(fontNamed: "Arial")
      perfect.text = "Perfect +1"
      perfect.name = GameSceneChildName.PerfectName.rawValue
      perfect.position = CGPointMake(0, -100)
      perfect.fontColor = SKColor.blackColor()
      perfect.fontSize = 50
      perfect.zPosition = GameSceneZposition.PerfectZposition.rawValue
      perfect.horizontalAlignmentMode = .Center
      perfect.alpha = 0

      addChild(perfect)

      return
    }

  }

  func loadBridge() -> SKSpriteNode {
    let hero = heroObj.getHeroNodeFromParent()

    let texture = SKTexture(imageNamed: "bridge")
    let bridge = SKSpriteNode(texture: texture, size: CGSizeMake(12, 1))
    bridge.zPosition = GameSceneZposition.BridgeZposition.rawValue
    bridge.name = GameSceneChildName.BridgeName.rawValue
    bridge.anchorPoint = CGPointMake(0.5, 0)
    bridge.position = CGPointMake(hero.position.x + hero.size.width / 2 + 18, hero.position.y - hero.size.height / 2)
    addChild(bridge)

    return bridge
  }

  func loadIslands(animate: Bool, startLeftPoint: CGFloat) -> SKSpriteNode {
    let max: Int = Int(IslandMaxWidth / 10)
    let min: Int = Int(IslandMinWidth / 10)
    let width: CGFloat = CGFloat(randomInRange(min...max) * 10)
    let height: CGFloat = IslandHeight
    let texture = SKTexture(imageNamed: "stone")
    let island = SKSpriteNode(texture: texture)
    island.size = CGSizeMake(width, height)
    island.zPosition = GameSceneZposition.IslandZposition.rawValue
    island.name = GameSceneChildName.IslandName.rawValue

    if animate {
      island.position = CGPointMake(DefinedScreenWidth / 2, -DefinedScreenHeight / 2 + height / 2)
      island.runAction(
        SKAction.moveToX(-DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3),
        completion: {[unowned self] () -> Void in
        self.isBegin = false
        self.isEnd = false
      })
    } else {
      island.position = CGPointMake(-DefinedScreenWidth / 2 + width / 2 + startLeftPoint, -DefinedScreenHeight / 2 + height / 2)
    }
    addChild(island)
    nextLeftStartX = width + startLeftPoint
    return island
  }

  func loadGameOverLayer() {
    let node = SKNode()
    node.alpha = 0
    node.name = GameSceneChildName.GameOverLayerName.rawValue
    node.zPosition = GameSceneZposition.GameOverZposition.rawValue
    addChild(node)

    let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    label.text = "Game Over"
    label.fontColor = SKColor.redColor()
    label.fontSize = 150
    label.position = CGPointMake(0, 100)
    label.horizontalAlignmentMode = .Center
    node.addChild(label)

    let retry = SKSpriteNode(imageNamed: "button_retry_up")
    retry.name = GameSceneChildName.RetryButtonName.rawValue
    retry.position = CGPointMake(0, -200)
    node.addChild(retry)
  }

  func randomInRange(range: Range<Int>) -> Int {
    let count = UInt32(range.endIndex - range.startIndex)
    return  Int(arc4random_uniform(count)) + range.startIndex
  }

}
