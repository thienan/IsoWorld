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

  var gameOver = false {
    willSet {
      if newValue {
        let gameOverLayer = childNodeWithName(GameSceneChildName.GameOverLayerName.rawValue) as SKNode?
        gameOverLayer?.runAction(SKAction.moveDistance(CGVectorMake(0, 100), fadeInWithDuration: 0.2))
      }

    }
  }

  let StackHeight: CGFloat = 400.0
  let StackMaxWidth: CGFloat = 300.0
  let StackMinWidth: CGFloat = 100.0
  let gravity: CGFloat = -100.0
  let StackGapMinWidth: Int = 80
  let HeroSpeed: CGFloat = 760

  var isBegin = false
  var isEnd = false
  var leftStack: SKShapeNode?
  var rightStack: SKShapeNode?

  var nextLeftStartX: CGFloat = 0
  var stickHeight: CGFloat = 0

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

      let stick = loadStick()
      let hero = childNodeWithName(GameSceneChildName.HeroName.rawValue) as? SKSpriteNode

      let action = SKAction.resizeToHeight(CGFloat(DefinedScreenHeight - StackHeight), duration: 1.5)
      stick.runAction(action, withKey: GameSceneActionKey.StickGrowAction.rawValue)

      let scaleAction = SKAction.sequence([SKAction.scaleYTo(0.9, duration: 0.05), SKAction.scaleYTo(1, duration: 0.05)])
      let loopAction = SKAction.group([SKAction.playSoundFileNamed(GameSceneEffectAudioName.StickGrowAudioName.rawValue, waitForCompletion: true)])
      stick.runAction(SKAction.repeatActionForever(loopAction), withKey: GameSceneActionKey.StickGrowAudioAction.rawValue)
      hero!.runAction(SKAction.repeatActionForever(scaleAction), withKey: GameSceneActionKey.HeroScaleAction.rawValue)

      return
    }

  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if isBegin && !isEnd {
      isEnd  = true

      let hero = childNodeWithName(GameSceneChildName.HeroName.rawValue) as? SKSpriteNode
      hero!.removeActionForKey(GameSceneActionKey.HeroScaleAction.rawValue)
      hero!.runAction(SKAction.scaleYTo(1, duration: 0.04))

      let stick = childNodeWithName(GameSceneChildName.StickName.rawValue) as? SKSpriteNode
      stick!.removeActionForKey(GameSceneActionKey.StickGrowAction.rawValue)
      stick!.removeActionForKey(GameSceneActionKey.StickGrowAudioAction.rawValue)
      stick!.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.StickGrowOverAudioName.rawValue, waitForCompletion: false))

      stickHeight = stick!.size.height

      let action = SKAction.rotateToAngle(CGFloat(-M_PI / 2), duration: 0.4, shortestUnitArc: true)
      let playFall = SKAction.playSoundFileNamed(GameSceneEffectAudioName.StickFallAudioName.rawValue, waitForCompletion: false)

      stick!.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), action, playFall]), completion: {[unowned self] () -> Void in
        self.heroGo(self.checkPass())
        })
    }
  }

  func start() {
    loadBackground()
    loadTip()
    loadGameOverLayer()

    leftStack = loadStacks(false, startLeftPoint: playAbleRect.origin.x)
    self.removeMidTouch(false, left: true)
    loadHero()

    let maxGap = Int(playAbleRect.width - StackMaxWidth - (leftStack?.frame.size.width)!)
    let gap = CGFloat(randomInRange(StackGapMinWidth...maxGap))
    rightStack = loadStacks(false, startLeftPoint: nextLeftStartX + gap)

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
    let stick = childNodeWithName(GameSceneChildName.StickName.rawValue) as? SKSpriteNode

    let rightPoint = DefinedScreenWidth / 2 + stick!.position.x + self.stickHeight

    guard rightPoint < self.nextLeftStartX else {
      return false
    }

    guard CGRectIntersectsRect((leftStack?.frame)!, stick!.frame)
      && CGRectIntersectsRect((rightStack?.frame)!, stick!.frame) else {
      return false
    }

    self.checkTouchMidStack()

    return true
  }

  private func checkTouchMidStack() {
    let stick = childNodeWithName(GameSceneChildName.StickName.rawValue) as? SKSpriteNode
    let stackMid = rightStack!.childNodeWithName(GameSceneChildName.StackMidName.rawValue) as? SKShapeNode

    let newPoint = stackMid!.convertPoint(CGPointMake(-10, 10), toNode: self)

    if (stick!.position.x + self.stickHeight) >= newPoint.x
      && (stick!.position.x + self.stickHeight) <= newPoint.x + 20 {
      loadPerfect()
      self.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.StickTouchMidAudioName.rawValue, waitForCompletion: false))
    }

  }

  private func removeMidTouch(animate: Bool, left: Bool) {

    let stack = left ? leftStack : rightStack
    let mid = stack!.childNodeWithName(GameSceneChildName.StackMidName.rawValue) as? SKShapeNode
    if animate {
      mid!.runAction(SKAction.fadeAlphaTo(0, duration: 0.3))
    }
    else {
      mid!.removeFromParent()
    }

  }

  private func heroGo(pass: Bool) {

    let hero = childNodeWithName(GameSceneChildName.HeroName.rawValue) as? SKSpriteNode

    guard pass else {
      let stick = childNodeWithName(GameSceneChildName.StickName.rawValue) as? SKSpriteNode

      let dis: CGFloat = stick!.position.x + self.stickHeight
      let disGap = nextLeftStartX - (DefinedScreenWidth / 2 - abs(hero!.position.x)) - (rightStack?.frame.size.width)! / 2

      let move = SKAction.moveToX(dis, duration: NSTimeInterval(abs(disGap / HeroSpeed)))

      hero!.runAction(walkAction, withKey: GameSceneActionKey.WalkAction.rawValue)
      hero!.runAction(move, completion: {[unowned self] () -> Void in
        stick!.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.4))

        hero!.physicsBody!.affectedByGravity = true
        hero!.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.DeadAudioName.rawValue, waitForCompletion: false))
        hero!.removeActionForKey(GameSceneActionKey.WalkAction.rawValue)
        self.runAction(SKAction.waitForDuration(0.5), completion: {[unowned self] () -> Void in
          self.gameOver = true
          })
        })

      return
    }

    let dis: CGFloat = -DefinedScreenWidth / 2 + nextLeftStartX - hero!.size.width / 2 - 20
    let disGap = nextLeftStartX - (DefinedScreenWidth / 2 - abs(hero!.position.x)) - (rightStack?.frame.size.width)! / 2

    let move = SKAction.moveToX(dis, duration: NSTimeInterval(abs(disGap / HeroSpeed)))

    hero!.runAction(walkAction, withKey: GameSceneActionKey.WalkAction.rawValue)
    hero!.runAction(move) { [unowned self] () -> Void in

      hero!.runAction(SKAction.playSoundFileNamed(GameSceneEffectAudioName.VictoryAudioName.rawValue, waitForCompletion: false))
      hero!.removeActionForKey(GameSceneActionKey.WalkAction.rawValue)
      self.moveStackAndCreateNew()
    }
  }

  private func moveStackAndCreateNew() {
    let action = SKAction.moveBy(CGVectorMake(-nextLeftStartX + (rightStack?.frame.size.width)! + playAbleRect.origin.x - 2, 0), duration: 0.3)
    rightStack?.runAction(action)
    self.removeMidTouch(true, left: false)

    let hero = childNodeWithName(GameSceneChildName.HeroName.rawValue) as? SKSpriteNode
    let stick = childNodeWithName(GameSceneChildName.StickName.rawValue) as? SKSpriteNode

    hero!.runAction(action)
    stick!.runAction(SKAction.group([SKAction.moveBy(CGVectorMake(-DefinedScreenWidth, 0), duration: 0.5), SKAction.fadeAlphaTo(0, duration: 0.3)])) { () -> Void in
      stick!.removeFromParent()
    }

    leftStack?.runAction(SKAction.moveBy(CGVectorMake(-DefinedScreenWidth, 0), duration: 0.5), completion: {[unowned self] () -> Void in
      self.leftStack?.removeFromParent()

      let maxGap = Int(self.playAbleRect.width - (self.rightStack?.frame.size.width)! - self.StackMaxWidth)
      let gap = CGFloat(self.randomInRange(self.StackGapMinWidth...maxGap))

      self.leftStack = self.rightStack
      self.rightStack = self.loadStacks(true, startLeftPoint: self.playAbleRect.origin.x + (self.rightStack?.frame.size.width)! + gap)
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
      let texture = SKTexture(image: UIImage(named: "stick_background.jpg")!)
      let node = SKSpriteNode(texture: texture)
      node.size = texture.size()
      node.zPosition = GameSceneZposition.BackgroundZposition.rawValue
      self.physicsWorld.gravity = CGVectorMake(0, gravity)

      addChild(node)
      return
    }
  }

  func loadHero() {
    let hero = SKSpriteNode(imageNamed: "human1")
    hero.name = GameSceneChildName.HeroName.rawValue
    hero.position = CGPointMake(-DefinedScreenWidth / 2 + nextLeftStartX - hero.size.width / 2 - 20, -DefinedScreenHeight / 2 + StackHeight + hero.size.height / 2 - 4)
    hero.zPosition = GameSceneZposition.HeroZposition.rawValue
    hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(16, 18))
    hero.physicsBody?.affectedByGravity = false
    hero.physicsBody?.allowsRotation = false

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

  func loadStick() -> SKSpriteNode {
    let hero = childNodeWithName(GameSceneChildName.HeroName.rawValue) as? SKSpriteNode

    let stick = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(12, 1))
    stick.zPosition = GameSceneZposition.StickZposition.rawValue
    stick.name = GameSceneChildName.StickName.rawValue
    stick.anchorPoint = CGPointMake(0.5, 0)
    stick.position = CGPointMake(hero!.position.x + hero!.size.width / 2 + 18, hero!.position.y - hero!.size.height / 2)
    addChild(stick)

    return stick
  }

  func loadStacks(animate: Bool, startLeftPoint: CGFloat) -> SKShapeNode {
    let max: Int = Int(StackMaxWidth / 10)
    let min: Int = Int(StackMinWidth / 10)
    let width: CGFloat = CGFloat(randomInRange(min...max) * 10)
    let height: CGFloat = StackHeight
    let stack = SKShapeNode(rectOfSize: CGSizeMake(width, height))
    stack.fillColor = SKColor.blackColor()
    stack.strokeColor = SKColor.blackColor()
    stack.zPosition = GameSceneZposition.StackZposition.rawValue
    stack.name = GameSceneChildName.StackName.rawValue

    if animate {
      stack.position = CGPointMake(DefinedScreenWidth / 2, -DefinedScreenHeight / 2 + height / 2)

      stack.runAction(SKAction.moveToX(-DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3), completion: {[unowned self] () -> Void in
        self.isBegin = false
        self.isEnd = false
        })

    } else {
      stack.position = CGPointMake(-DefinedScreenWidth / 2 + width / 2 + startLeftPoint, -DefinedScreenHeight / 2 + height / 2)
    }
    addChild(stack)

    let mid = SKShapeNode(rectOfSize: CGSizeMake(20, 20))
    mid.fillColor = SKColor.redColor()
    mid.strokeColor = SKColor.redColor()
    mid.zPosition = GameSceneZposition.StackMidZposition.rawValue
    mid.name = GameSceneChildName.StackMidName.rawValue
    mid.position = CGPointMake(0, height / 2 - 20 / 2)
    stack.addChild(mid)

    nextLeftStartX = width + startLeftPoint

    return stack
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
