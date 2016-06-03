//
//  Rating.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/22/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import SpriteKit
import RxSwift

class RatingScene: SKScene {

  private var scaleOffset: CGFloat = 1.0
  private var panOffset = CGPointZero
  private let viewIso: SKSpriteNode

  private var selectedObj: UserNode?
  private let userService = UserService()
  private var users = Array<Array<UserScore>>()

  private var userName: SKLabelNode!
  private var timeCircle: SKShapeNode!
  private var timeLabel: SKLabelNode!
  private var disposeBag = DisposeBag()

  private let tileSize = (width: 32, height: 32)

  private var pinchRecognizer: UIPinchGestureRecognizer?
  private var panGestureRecognizer: UIPanGestureRecognizer?

  override init(size: CGSize) {
    viewIso = SKSpriteNode()
    super.init(size: size)
    self.view?.ignoresSiblingOrder = true
    self.backgroundColor = UIColor.whiteColor()

    addUserNameNode()
    addBackButton()
    addTimeCircle()
  }
  
  private func addUserNameNode() {
    self.userName = SKLabelNode()
    self.userName.fontColor = UIColor.blackColor()
    self.userName.fontSize = 30
    self.userName.horizontalAlignmentMode = .Center
    self.userName.position = CGPoint(
      x: 200,
      y: size.height - 35
    )
    self.userName.zPosition = 200
    self.addChild(userName)
  }

  private func addBackButton() {
    let backButton = SKSpriteNode()
    backButton.position = CGPointMake(35, size.height - 35)
    backButton.texture = SKTexture(imageNamed: "left_arrow")
    backButton.zPosition = 300
    backButton.colorBlendFactor = 1.0
    backButton.alpha = 1.0
    backButton.color = UIColor.whiteColor()
    backButton.size.height = 33
    backButton.size.width = 33
    addChild(backButton)

    let backButtonPlace = SKSpriteNode()
    backButtonPlace.position = CGPointMake(35, size.height - 35)
    backButtonPlace.zPosition = 10000
    backButtonPlace.colorBlendFactor = 1.0
    backButtonPlace.alpha = 1.0
    backButtonPlace.color = UIColor.clearColor()
    backButtonPlace.size.height = 100
    backButtonPlace.size.width = 100
    backButtonPlace.name = "back"
    addChild(backButtonPlace)
  }
  
  func addTimeCircle() {
    self.timeCircle = SKShapeNode(circleOfRadius: 25)
    self.timeCircle.position = CGPoint(
      x: size.width - 50,
      y: size.height - 35
    )
    self.timeCircle.strokeColor = SKColor.blackColor()
    self.timeCircle.glowWidth = 0.01
    self.timeCircle.fillColor = SKColor.orangeColor()
    self.timeCircle.alpha = 0.0
    self.addChild(timeCircle)
    
    self.timeLabel = SKLabelNode()
    self.timeLabel.fontColor = UIColor.whiteColor()
    self.timeLabel.fontName = self.timeLabel.fontName! + "-Bold"
    self.timeLabel.fontSize = 30
    self.timeLabel.horizontalAlignmentMode = .Center
    self.timeLabel.position = CGPoint(
      x: size.width - 50,
      y: size.height - 45
    )
    self.timeLabel.zPosition = 200
    self.addChild(timeLabel)
    
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToView(view: SKView) {
    let deviceScale = self.size.width/667
    viewIso.position =  CGPoint(x: 200, y: 200)
    viewIso.xScale = deviceScale
    viewIso.yScale = deviceScale
    addChild(viewIso)

    scores.asObservable().subscribe {
      score in
      self.viewIso.removeAllChildren()
      self.users = self.userService.convertUserScoresToMatrix(fromVector: score.element!)
      self.placeAllTilesIso()
    }
    .addDisposableTo(disposeBag)

    pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture(_:)))
    self.pinchRecognizer!.delaysTouchesBegan = true
    self.view!.addGestureRecognizer(pinchRecognizer!)

    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(_:)))
    panGestureRecognizer!.delaysTouchesBegan = true
    self.view!.addGestureRecognizer(panGestureRecognizer!)
  }

  private func placeTileIso(withPosition: CGPoint, withTexture texture: SKTexture) -> SKSpriteNode {
    let tileSprite = SKSpriteNode(texture: texture)
    tileSprite.position = withPosition
    tileSprite.alpha = 1.0
    tileSprite.colorBlendFactor = 1.0
    tileSprite.color = SKColor.whiteColor()
    tileSprite.anchorPoint =  CGPoint(x: 0, y: 0)
    return tileSprite
  }

  private func placeAllTilesIso() {
    for i in 0..<users.count {
      let row = users[i]
      for j in 0..<row.count {
        let visible = getVisibleIndex(users, indexI: i, indexJ: j)
        let texture = getColumnTexture(row[j])
        let column = getCoumn(row[j])

        if row[j].score > 0 {
          if j > 0 || i > 0 {
            let spriteIndexes = getDrawableNodeIndex(1, score: row[j].score, visible: visible)
            for index in spriteIndexes {
              let point = getCoordinatesByIndex(i, indexJ: j, index: -index, inversed: false)
              column.addChild(placeTileIso(point, withTexture: texture))
            }
          } else {
            let spriteIndexes = getDrawableNodeIndex(0, score: row[j].score, visible: visible)
            for index in spriteIndexes {
              let point = getCoordinatesByIndex(i, indexJ: j, index: -index, inversed: false)
              column.addChild(placeTileIso(point, withTexture: texture))
            }
          }
        } else {
          let point = getCoordinatesByIndex(i, indexJ: j, index: 0, inversed: false)
          column.addChild(placeTileIso(point, withTexture: texture))
        }
        column.userObj = row[j]
        viewIso.addChild(column)
      }
    }
  }

  private func getDrawableNodeIndex(
    startIndex: Int,
    score: Int,
    visible: Int) -> Array<Int> {
    let rangeArray = Array(startIndex..<score + 2)
    if visible > 0 {
      let index = rangeArray.indexOf(visible)!..<rangeArray.count
      return Array(index)
    } else {
      let index = 1..<rangeArray.count
      return Array(index)
    }
  }

  private func getColumnTexture(userScore: UserScore) -> SKTexture {
    var texture = SKTexture(imageNamed: "iso_wall_blue")
    if userScore.me {
      texture = SKTexture(imageNamed: "iso_wall_yellow")
    } else {
      if userScore.score > 0 {
        if userScore.time > 0 && userScore.time < 21 {
          texture = SKTexture(imageNamed: "iso_wall_blue")
        } else if userScore.time > 20 && userScore.time < 41 {
          texture = SKTexture(imageNamed: "iso_wall_green")
        } else if userScore.time > 40 {
          texture = SKTexture(imageNamed: "iso_wall_red")
        }
      } else {
        texture = SKTexture(imageNamed: "iso_ground")
      }
    }
    return texture
  }

  private func getCoumn(userScore: UserScore) -> UserNode {
    let column = UserNode()
    column.name =  String(userScore.score)
    column.colorBlendFactor = 1.0
    column.alpha = 1.0
    return column
  }

  private func isColumn(value: Int) -> Bool {
    var status = false
    if value > 0 {
      status = true
    }
    return status
  }

  private func getCoordinatesByIndex(
    indexI: Int,
    indexJ: Int,
    index: Int,
    inversed: Bool) -> CGPoint {
    var x = 0
    var y = 0
    if !inversed {
      x = (indexJ * tileSize.width) + tileSize.height * index
      y = -(indexI * tileSize.height + tileSize.height  * index)
    } else {
      x = -((indexJ * tileSize.width) + tileSize.height * index)
      y = indexI * tileSize.height + tileSize.height  * index
    }
    let point = CGPoint(x: x, y: y)
    return point2DToIso(point)
  }

  private func getVisibleIndex(
    userScores: Array<Array<UserScore>>,
    indexI: Int,
    indexJ: Int) -> Int {
    var right = 0
    if userScores.indices.contains(indexI + 1) {
      right = userScores[indexI + 1][indexJ].score
    }

    var down = 0
    if users[indexI].indices.contains(indexJ + 1) {
      down = userScores[indexI][indexJ + 1].score
    }

    return min(right, down)
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))

      if nodeAtTouch.name == "back" {
        let scene = MenuScene()
        let skView = self.view
        scene.size = skView!.bounds.size
        scene.scaleMode = .AspectFill

        self.view?.removeGestureRecognizer(pinchRecognizer!)
        self.view?.removeGestureRecognizer(panGestureRecognizer!)

        skView!.presentScene(scene)
      } else {
        if let parent = nodeAtTouch.parent as? UserNode {
          if let name = parent.name {
            if Int(name) != nil {
              deselectColumn()
              selectColumn(parent)
            }
          }
        }
      }
    }
  }

  private func deselectColumn() {
    if let selected = selectedObj {
      for element in (selected.children as? [SKSpriteNode])! {
        element.color = UIColor.whiteColor()
      }
    }
  }

  private func selectColumn(column: UserNode) {
    self.selectedObj = column
    for element in (column.children as? [SKSpriteNode])! {
      element.color = UIColor.cyanColor()
      self.userName.text = column.userObj?.name
      self.timeCircle.alpha = 1.0
      
      if column.userObj?.time > 0 && column.userObj?.time < 21 {
        self.timeCircle.fillColor = SKColor.blueColor()
      } else if column.userObj?.time > 20 && column.userObj?.time < 41 {
        self.timeCircle.fillColor = SKColor.greenColor()
      } else if column.userObj?.time > 40 {
        self.timeCircle.fillColor = SKColor.redColor()
      }
      self.timeLabel.text = "\(column.userObj!.time)"
      
      
    }
  }

  private func onPinchStart(centroid: CGPoint, scale: CGFloat) {
    scaleOffset = viewIso.xScale
  }

  private func onPinchMove(centroid: CGPoint, scale: CGFloat) {
    let xScale = (scale - 1.0) + scaleOffset
    let yScale = (scale - 1.0) + scaleOffset
    if xScale > 0 && yScale > 0 {
      self.viewIso.xScale = xScale
      self.viewIso.yScale = yScale
    }
  }
  
  @objc private func pinchGesture(gestureRecognizer: UIPinchGestureRecognizer) {
    let scale = gestureRecognizer.scale
    let centroid = gestureRecognizer.locationInView(self.view)
    
    switch gestureRecognizer.state {
    case .Began:
      self.onPinchStart(centroid, scale: scale)
    default:
      self.onPinchMove(centroid, scale: scale)
    }
  }

  @objc private func onPan(gestureRecognizer: UIPanGestureRecognizer) {
    let y = -(gestureRecognizer.locationInView(self.view).y - self.view!.frame.height)
    let x = gestureRecognizer.locationInView(self.view).x

    self.viewIso.position =  CGPoint(x: x, y: y)

  }

}
