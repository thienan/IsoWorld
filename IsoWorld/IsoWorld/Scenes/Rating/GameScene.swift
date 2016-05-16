import SpriteKit

class GameScene: SKScene {

  private var scaleOffset: CGFloat = 1.0
  private var panOffset = CGPointZero
  private let viewIso: SKSpriteNode

  var selectedObj: UserNode?
  let userService = UserService()
  var users = Array<Array<UserScore>>()

  var userName: SKLabelNode!
  var userAvatar: SKSpriteNode!

  let tileSize = (width: 32, height: 32)

  override init(size: CGSize) {
    viewIso = SKSpriteNode()
    super.init(size: size)
    self.view?.ignoresSiblingOrder = true
    self.backgroundColor = UIColor.whiteColor()
    let scores = userService.loadUserRating()
    users = userService.convertUserScoresToMatrix(fromVector: scores)
    self.userName = SKLabelNode()
    self.userName.fontColor = UIColor.blackColor()
    self.userName.fontSize = 30
    self.userName.position = CGPoint(
      x: 200,
      y: size.height - 35
    )
    self.userName.zPosition = 200
    self.addChild(userName)

    self.userAvatar = SKSpriteNode()
    self.userAvatar.position = CGPoint(
      x: 60,
      y: size.height - 70
    )
    userAvatar.size.height = 80
    userAvatar.size.width = 90
    userAvatar.color = UIColor.redColor()
    userAvatar.zPosition = 200
    self.addChild(userAvatar)
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

    placeAllTilesIso()
  }

  func placeTileIso(image: String, withPosition: CGPoint, color: UIColor) -> SKSpriteNode {
    let texture = SKTexture(imageNamed: image)
    let tileSprite = SKSpriteNode(texture: texture)
    tileSprite.position = withPosition
    tileSprite.colorBlendFactor = 1.0
    tileSprite.alpha = 1.0

    if color != UIColor.clearColor() {
      tileSprite.color = color
    } else {
      tileSprite.color = UIColor.whiteColor()
    }

    tileSprite.anchorPoint =  CGPoint(x: 0, y: 0)
    return tileSprite
  }

  func placeAllTilesIso() {
    for i in 0..<users.count {
      let row = users[i]
      for j in 0..<row.count {
        let visible = getVisibleIndex(users, indexI: i, indexJ: j)
        let tileInt = row[j].score
        let color = getColumnColor(row[j])
        let tile = Tile(rawValue: tileInt > 0 ? 1 : 0)!
        let column = getCoumn(row[j])
        let point = getCoordinatesByIndex(i, indexJ: j, index: 0, inversed: false)
        column.addChild(placeTileIso(("iso_" + tile.image), withPosition: point, color: color))

        if row[j].score > 1 {
          if j > 0 || i > 0 {
            let spriteIndexes = getDrawableNodeIndex(1, score: row[j].score, visible: visible)
            for index in spriteIndexes {
              let point = getCoordinatesByIndex(i, indexJ: j, index: -index, inversed: false)
              column.addChild(placeTileIso(("iso_" + tile.image), withPosition: point, color: color))
            }
          } else {
            let spriteIndexes = getDrawableNodeIndex(0, score: row[j].score, visible: visible)
            for index in spriteIndexes {
              let point = getCoordinatesByIndex(i, indexJ: j, index: -index, inversed: false)
              column.addChild(placeTileIso(("iso_" + tile.image), withPosition: point, color: color))
            }
          }
        }
        column.userObj = row[j]
        viewIso.addChild(column)
      }
    }
  }

  func getDrawableNodeIndex(startIndex: Int, score: Int, visible: Int) -> Array<Int> {
    let rangeArray = Array(startIndex..<score + 1)
    if visible > 0 {
      let index = rangeArray.indexOf(visible)!..<rangeArray.count
      return Array(index)
    } else {
      let index = 1..<rangeArray.count
      return Array(index)
    }
  }

  func getColumnColor(userScore: UserScore) -> SKColor {
    var color = UIColor.clearColor()
    if userScore.me {
      color = UIColor.redColor()
    } else {
      color = UIColor.clearColor()
    }
    return color
  }

  func getCoumn(userScore: UserScore) -> UserNode {
    let column = UserNode()
    column.name =  String(userScore.score)
    column.colorBlendFactor = 1.0
    column.alpha = 1.0
    return column
  }

  func isColumn(value: Int) -> Bool {
    var status = false
    if value > 0 {
      status = true
    }
    return status
  }

  func getCoordinatesByIndex(indexI: Int, indexJ: Int, index: Int, inversed: Bool) -> CGPoint {
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

  func getVisibleIndex(userScores: Array<Array<UserScore>>, indexI: Int, indexJ: Int) -> Int {
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

  func deselectColumn() {
    if let selected = selectedObj {
      for element in (selected.children as? [SKSpriteNode])! {
        if selected.userObj?.me == true {
          element.color = UIColor.redColor()
        } else {
          element.color = UIColor.whiteColor()
        }
      }
    }
  }

  func selectColumn(column: UserNode) {
    self.selectedObj = column
    for element in (column.children as? [SKSpriteNode])! {
      element.color = UIColor.blueColor()
      self.userName.text = column.userObj?.name
      let texture = SKTexture(imageNamed: (column.userObj?.photo)!)
      self.userAvatar.texture = texture
    }
  }

  func onPinchStart(centroid: CGPoint, scale: CGFloat) {
    scaleOffset = viewIso.xScale
  }

  func onPinchMove(centroid: CGPoint, scale: CGFloat) {
    let xScale = (scale - 1.0) + scaleOffset
    let yScale = (scale - 1.0) + scaleOffset
    if xScale > 0 && yScale > 0 {
      self.viewIso.xScale = xScale
      self.viewIso.yScale = yScale
    }
  }

  func onPan(gestureRecognizer: UIPanGestureRecognizer) {
    let y = -(gestureRecognizer.locationInView(self.view).y - self.view!.frame.height)
    let x = gestureRecognizer.locationInView(self.view).x

    self.viewIso.position =  CGPoint(x: x, y: y)

  }

}
