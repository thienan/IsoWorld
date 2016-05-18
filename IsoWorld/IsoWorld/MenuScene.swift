//
//  MenuScene.swift
//  LightFlow
//
//  Created by rmuhamedgaliev on 13/03/16.
//  Copyright © 2016 rmuhamedgaliev. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
  var titleLabel: SKLabelNode?
  var newGameLabel: SKLabelNode?

  var gameScene: GameScene!

  override func didMoveToView(view: SKView) {

    self.backgroundColor = UIColor(red: 0.20392156862745106, green: 0.5960784313725489, blue: 0.8588235294117647, alpha: 1)

    addNewGame()
  }

  private func addNewGame() {
    self.newGameLabel = SKLabelNode()
    self.newGameLabel?.fontSize = 36
    self.newGameLabel?.fontColor = UIColor.whiteColor()
    self.newGameLabel?.text = "RATING".localized
    self.newGameLabel?.name = "rating"
    self.newGameLabel?.position = CGPoint(x: CGRectGetMidX((self.scene?.frame)!), y: CGRectGetMidY((self.scene?.frame)!) - 100)
    self.addChild(newGameLabel!)
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.menuHelper(touches)
  }

  private func menuHelper(touches: Set<UITouch>) {
    for touch in touches {
      let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))
      if nodeAtTouch.name == "title" {
        print("Title")
      } else if nodeAtTouch.name == "rating" {

        let scene = GameScene(size: view!.bounds.size)
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
