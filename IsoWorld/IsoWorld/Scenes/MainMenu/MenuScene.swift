//
//  MenuScene.swift
//  LightFlow
//
//  Created by rmuhamedgaliev on 13/03/16.
//  Copyright © 2016 rmuhamedgaliev. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
  var logoNode: SKSpriteNode?
  var gameLabel: SKLabelNode?
  var ratingLabel: SKLabelNode?

  var gameScene: Rating!

  override func didMoveToView(view: SKView) {

    self.backgroundColor = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1)

    addLogo()
    addNewGameTitle()
    addRatingTitle()
  }
  
  private func addLogo() {
    let size = CGSize(width: 250, height: 250)
    self.logoNode = SKSpriteNode(imageNamed: "logo")
    self.logoNode?.size = size
    self.logoNode?.position = CGPoint(
      x: CGRectGetMidX((self.scene?.frame)!),
      y: CGRectGetHeight((self.scene?.frame)!) - 200
    )
    
    self.addChild(self.logoNode!)
  }

  private func addNewGameTitle() {
    self.gameLabel = SKLabelNode()
    self.gameLabel?.fontSize = 36
    self.gameLabel?.fontColor = UIColor.whiteColor()
    self.gameLabel?.text = "GAME".localized
    self.gameLabel?.name = "game"
    self.gameLabel?.fontName = "Cinzel-Regular"
    self.gameLabel?.position = CGPoint(x: CGRectGetMidX((self.scene?.frame)!), y: CGRectGetMidY((self.scene?.frame)!) - 50)
    self.addChild(gameLabel!)
  }

  private func addRatingTitle() {
    self.ratingLabel = SKLabelNode()
    self.ratingLabel?.fontSize = 36
    self.ratingLabel?.fontColor = UIColor.whiteColor()
    self.ratingLabel?.text = "RATING".localized
    self.ratingLabel?.name = "rating"
    self.ratingLabel?.fontName = "Cinzel-Regular"
    self.ratingLabel?.position = CGPoint(x: CGRectGetMidX((self.scene?.frame)!), y: CGRectGetMidY((self.scene?.frame)!) - 100)
    self.addChild(ratingLabel!)
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.menuHelper(touches)
  }

  private func menuHelper(touches: Set<UITouch>) {
    for touch in touches {
      let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))
      if nodeAtTouch.name == "game" {
        let scene = GameScene(size: CGSizeMake(DefinedScreenWidth, DefinedScreenHeight))

        // Configure the view.
        let skView = self.view
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView!.ignoresSiblingOrder = true

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill

        skView!.presentScene(scene)
      } else if nodeAtTouch.name == "rating" {

        let scene = Rating(size: view!.bounds.size)
        let skView = self.view
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = (skView?.bounds.size)!

        let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(MenuScene.pinchGesture(_:)))
        recognizer.delaysTouchesBegan = true
        skView!.addGestureRecognizer(recognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MenuScene.onPan(_:)))
        panGestureRecognizer.delaysTouchesBegan = true
        skView!.addGestureRecognizer(panGestureRecognizer)

        skView!.presentScene(scene)
        self.gameScene = scene
      }
    }
  }

  func pinchGesture(gestureRecognizer: UIPinchGestureRecognizer) {
    let scale = gestureRecognizer.scale
    let centroid = gestureRecognizer.locationInView(self.view)

    switch gestureRecognizer.state {
    case .Began:
      self.gameScene.onPinchStart(centroid, scale: scale)
    default:
      self.gameScene.onPinchMove(centroid, scale: scale)
    }
  }

  func onPan(gestureRecognizer: UIPanGestureRecognizer) {
    self.gameScene.onPan(gestureRecognizer)
  }

}
