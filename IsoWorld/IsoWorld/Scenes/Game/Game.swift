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
  private var musicPlayer: AVAudioPlayer!
  private var backButton: SKSpriteNode!

//  MARK: Hero
  private var heroObj =  Hero()
//  MARK: Island
  private var islandObj = Island()
  private var leftIsland: SKSpriteNode?
  private var rightIsland: SKSpriteNode?
  private let gravity: CGFloat = -100.0
  private let HeroSpeed: CGFloat = 760
  private var isBegin = false
  private var isEnd = false
  private var nextLeftStartX: CGFloat = 0
  private var bridgeHeight: CGFloat = 0

  private lazy var playAbleRect: CGRect = {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = self.size.height / maxAspectRatio
    let playableMargin = (self.size.width - maxAspectRatioWidth) / 2.0
    return CGRectMake(playableMargin, 0, maxAspectRatioWidth, self.size.height)
  }()

  private var gameOver = false {
    willSet {
      if newValue {
        let gameOverLayer = childNodeWithName(GameSceneChildName.GameOverLayerName.rawValue) as SKNode?
        gameOverLayer?.runAction(SKAction.moveDistance(CGVectorMake(0, 100), fadeInWithDuration: 0.2))
      }
    }
  }

  private var score: Int = 0 {
    willSet {
      let scoreBand = childNodeWithName(GameSceneChildName.ScoreName.rawValue) as? SKLabelNode
      scoreBand?.text = "\(newValue)"
      scoreBand?.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration: 0.1), SKAction.scaleTo(1, duration: 0.1)]))

      if newValue == 1 {
        let tip = childNodeWithName(GameSceneChildName.TipName.rawValue) as? SKLabelNode
        tip?.runAction(SKAction.fadeAlphaTo(0, duration: 0.4))
      }
    }
  }

  // MARK: - override
  override init(size: CGSize) {
    super.init(size: size)
    anchorPoint = CGPointMake(0.5, 0.5)
    physicsWorld.contactDelegate = self

    musicPlayer = setupAudioPlayerWithFile("bg_country", type: "mp3")
    musicPlayer.numberOfLoops = -1
    musicPlayer.play()
  }

  override func didMoveToView(view: SKView) {
    start()
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = (touch as UITouch).locationInNode(self)
      if let touchNode = self.nodeAtPoint(location) as? SKSpriteNode {
        if touchNode.name == "back" {
          let scene = MenuScene()
          let skView = self.view
          scene.size = skView!.bounds.size
          scene.scaleMode = .AspectFill
          skView!.presentScene(scene)
        } else {
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
            let action = SKAction.resizeToHeight(
              CGFloat(
                DefinedScreenHeight - IslandConstants.height
              ),
              duration: 1.5
            )
            bridge.runAction(action, withKey: GameSceneActionKey.BridgeGrowAction.rawValue)
            let loopAction = SKAction.group(
              [SKAction.playSoundFileNamed(
                GameSceneEffectAudioName.BridgeGrowAudioName.rawValue,
                waitForCompletion: true)]
            )
            bridge.runAction(
              SKAction.repeatActionForever(loopAction),
              withKey: GameSceneActionKey.BridgeGrowAudioAction.rawValue
            )
            return
          }
        }
      }
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
      bridge!.runAction(
        SKAction.playSoundFileNamed(
          GameSceneEffectAudioName.BridgeGrowOverAudioName.rawValue, waitForCompletion: false
        )
      )

      bridgeHeight = bridge!.size.height

      let action = SKAction.rotateToAngle(
        CGFloat(-M_PI / 2),
        duration: 0.4,
        shortestUnitArc: true
      )
      let playFall = SKAction.playSoundFileNamed(
        GameSceneEffectAudioName.BridgeFallAudioName.rawValue,
        waitForCompletion: false
      )
      bridge!.runAction(
        SKAction.sequence(
          [SKAction.waitForDuration(0.2), action, playFall]),
        completion: {[unowned self] () -> Void in
        self.heroGo(self.checkPass())
        })
    }
  }

//  MARK: Audio player
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

  private func start() {
    loadBackground()
    loadScoreBackground()
    loadScore()
    loadTip()
    loadBackButton()
    loadGameOverLayer()
    addleftIsland(false)
    loadHero()

    let rightIslandStartPosition = islandObj.calculateGap(
      self.playAbleRect.width,
      leftIslandWidth: self.leftIsland!.size.width,
      nextLeftStartX: self.nextLeftStartX
    )

    addRightIsland(false, rightIslandStartPosition: rightIslandStartPosition)
    gameOver = false
  }

  private func addleftIsland(animated: Bool) {
    let leftIslandData = islandObj.loadIslands(
      animated,
      startLeftPoint: playAbleRect.origin.x,
      completition: {[unowned self] () -> Void in
        self.isBegin = false
        self.isEnd = false
      }
    )

    self.leftIsland = leftIslandData.islandNode
    addChild(self.leftIsland!)
    self.nextLeftStartX = leftIslandData.leftStartX
  }

  private func addRightIsland(
    animated: Bool,
    rightIslandStartPosition: CGFloat) {

    let rightIslandData = islandObj.loadIslands(
      animated,
      startLeftPoint: rightIslandStartPosition,
      completition: {[unowned self] () -> Void in
        self.isBegin = false
        self.isEnd = false
      }
    )

    self.rightIsland = rightIslandData.islandNode
    self.addChild(self.rightIsland!)
    self.nextLeftStartX = rightIslandData.leftStartX
  }

  private func restart() {
    isBegin = false
    isEnd = false
    score = 0
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
      let bridge = childNodeWithName(
        GameSceneChildName.BridgeName.rawValue) as? SKSpriteNode
      let dis: CGFloat = bridge!.position.x + self.bridgeHeight
      let disGap = nextLeftStartX
        - (DefinedScreenWidth / 2
        - abs(hero.position.x))
        - (rightIsland?.frame.size.width)! / 2
      let move = SKAction.moveToX(dis, duration: NSTimeInterval(abs(disGap / HeroSpeed)))
      hero.runAction(heroObj.walkAction, withKey: GameSceneActionKey.WalkAction.rawValue)
      hero.runAction(move, completion: {[unowned self] () -> Void in
        bridge!.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.4))
        hero.physicsBody!.affectedByGravity = true
        hero.runAction(
          SKAction.playSoundFileNamed(
            GameSceneEffectAudioName.DeadAudioName.rawValue, waitForCompletion: false
          )
        )
        hero.removeActionForKey(GameSceneActionKey.WalkAction.rawValue)
        self.runAction(SKAction.waitForDuration(0.5), completion: {[unowned self] () -> Void in
          self.gameOver = true
          })
        })
      return
    }

    let dis: CGFloat = -DefinedScreenWidth / 2 + nextLeftStartX - hero.size.width / 2 - 20
    let disGap = nextLeftStartX
      - (DefinedScreenWidth / 2
      - abs(hero.position.x))
      - (rightIsland?.frame.size.width)! / 2
    let move = SKAction.moveToX(dis, duration: NSTimeInterval(abs(disGap / HeroSpeed)))
    hero.runAction(heroObj.walkAction, withKey: GameSceneActionKey.WalkAction.rawValue)
    hero.runAction(move) { [unowned self] () -> Void in
      hero.runAction(
        SKAction.playSoundFileNamed(
          GameSceneEffectAudioName.VictoryAudioName.rawValue, waitForCompletion: false
        )
      )
      hero.removeActionForKey(GameSceneActionKey.WalkAction.rawValue)
      self.moveIslandAndCreateNew()
    }
    self.score += 1
  }

  private func moveIslandAndCreateNew() {
    let action = SKAction.moveBy(
      CGVectorMake(
        -nextLeftStartX
        + (rightIsland?.frame.size.width)!
        + playAbleRect.origin.x - 2,
        0
      ),
      duration: 0.3
    )
    rightIsland?.runAction(action)
    let hero = heroObj.getHeroNodeFromParent()
    let bridge = childNodeWithName(GameSceneChildName.BridgeName.rawValue) as? SKSpriteNode
    hero.runAction(action)
    bridge!.runAction(
      SKAction.group(
      [SKAction.moveBy(
        CGVectorMake(-DefinedScreenWidth, 0),
        duration: 0.5
        ),
        SKAction.fadeAlphaTo(0, duration: 0.3)
        ])) { () -> Void in
      bridge!.removeFromParent()
    }
    leftIsland?.runAction(SKAction.moveBy(
      CGVectorMake(-DefinedScreenWidth, 0), duration: 0.5),
                          completion: {[unowned self] () -> Void in
      self.leftIsland?.removeFromParent()
      let maxGap = Int(self.playAbleRect.width
        - (self.rightIsland?.frame.size.width)!
        - IslandConstants.maxWidth)
      let gap = CGFloat(randomInRange(IslandConstants.gapMinWidth...maxGap))
      self.leftIsland = self.rightIsland
      let rightIslandStartPosition =
        self.playAbleRect.origin.x + (self.rightIsland?.frame.size.width)! + gap
      self.addRightIsland(true, rightIslandStartPosition: rightIslandStartPosition)
    })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - load node
private extension GameScene {

  private func loadBackground() {
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

  private func loadHero() {
    let hero = heroObj.getHeroNode(
      nextLeftStartX: self.nextLeftStartX,
      islandHeight: self.leftIsland!.size.height
    )
    addChild(hero)
  }

  private func loadBridge() -> SKSpriteNode {
    let hero = heroObj.getHeroNodeFromParent()
    let texture = SKTexture(imageNamed: "bridge")
    let bridge = SKSpriteNode(texture: texture, size: CGSizeMake(12, 1))
    bridge.zPosition = GameSceneZposition.BridgeZposition.rawValue
    bridge.name = GameSceneChildName.BridgeName.rawValue
    bridge.anchorPoint = CGPointMake(0.5, 0)
    bridge.position = CGPointMake(hero.position.x + hero.size.width / 2 + 18, hero.position.y - hero.size.height / 2)
    addChild(bridge)

    print(bridge.size.height)

    return bridge
  }

  private func loadGameOverLayer() {
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

  private func loadScore() {
    let scoreBand = SKLabelNode(fontNamed: "Arial")
    scoreBand.name = GameSceneChildName.ScoreName.rawValue
    scoreBand.text = "0"
    scoreBand.position = CGPointMake(0, DefinedScreenHeight / 2 - 200)
    scoreBand.fontColor = SKColor.whiteColor()
    scoreBand.fontSize = 100
    scoreBand.zPosition = GameSceneZposition.ScoreZposition.rawValue
    scoreBand.horizontalAlignmentMode = .Center
    
    addChild(scoreBand)
  }
  
  private func loadBackButton() {
    let backButton = SKSpriteNode()
    backButton.position = CGPointMake(-470, DefinedScreenHeight / 2 - 150)
    backButton.texture = SKTexture(imageNamed: "left_arrow")
    backButton.zPosition = 300
    backButton.colorBlendFactor = 1.0
    backButton.alpha = 1.0
    backButton.color = UIColor.whiteColor()
    backButton.size.height = 99
    backButton.size.width = 99
    addChild(backButton)
    
    let backButtonPlace = SKSpriteNode()
    backButtonPlace.position = CGPointMake(-470, DefinedScreenHeight / 2 - 150)
    backButtonPlace.zPosition = 10000
    backButtonPlace.colorBlendFactor = 1.0
    backButtonPlace.alpha = 1.0
    backButtonPlace.color = UIColor.clearColor()
    backButtonPlace.size.height = 200
    backButtonPlace.size.width = 200
    backButtonPlace.name = "back"
    addChild(backButtonPlace)
  }

  private func loadScoreBackground() {
    let back = SKShapeNode(rect: CGRectMake(0-120, 1024-200-30, 240, 140), cornerRadius: 20)
    back.zPosition = GameSceneZposition.ScoreBackgroundZposition.rawValue
    back.fillColor = SKColor.blackColor().colorWithAlphaComponent(0.3)
    back.strokeColor = SKColor.blackColor().colorWithAlphaComponent(0.3)
    addChild(back)
  }

  private func loadTip() {
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

}
