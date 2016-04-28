import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGPoint) -> CGPoint {
  return CGPoint(x: point.x * scalar.x, y: point.y * scalar.y)
}

func / (point: CGPoint, scalar: CGPoint) -> CGPoint {
  return CGPoint(x: point.x / scalar.x, y: point.y / scalar.y)
}

enum Tile: Int {

  case Ground
  case Wall

  var description:String {
    switch self {
    case Ground:
      return "Ground"
    case Wall:
      return "Wall"
    }
  }

  var image:String {
    switch self {
    case Ground:
      return "ground"
    case Wall:
      return "wall"

    }
  }
}

class GameScene: SKScene {

  private var _scaleOffset: CGFloat = 1.0
  private var _panOffset = CGPointZero
  let viewIso:SKSpriteNode

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


    let tiles = [[9, 9, 9, 9, 9, 8, 7, 7, 6, 5], [9, 9, 9, 9, 8, 7, 7, 6, 5, 4], [9, 9, 9, 8, 8, 7, 6, 5, 4, 3], [9, 9, 8, 8, 7, 6, 5, 4, 3, 2], [9, 8, 8, 7, 6, 5, 5, 3, 2, 1], [9, 8, 7, 6, 5, 5, 3, 2, 1, 1], [8, 7, 6, 6, 5, 3, 2, 2, 1, 1], [7, 6, 6, 5, 4, 2, 2, 1, 1, 0], [6, 6, 5, 4, 2, 2, 1, 1, 0, 0], [6, 5, 4, 2, 2, 1, 1, 0, 0, 0]]

  let tileSize = (width:32, height:32)

  override init(size: CGSize) {
    viewIso = SKSpriteNode()
    super.init(size: size)
    self.view?.ignoresSiblingOrder = true
    self.backgroundColor = UIColor.whiteColor()
  }


  override func didMoveToView(view: SKView) {

    let deviceScale = self.size.width/667

    viewIso.position = CGPoint(x: 200, y: 200)
    viewIso.xScale = deviceScale
    viewIso.yScale = deviceScale
    addChild(viewIso)

    placeAllTilesIso()
  }

  func point2DToIso(p:CGPoint, inverse: Bool) -> CGPoint {

    //invert y pre conversion
    var point = p * CGPoint(x:1, y:-1)

    //convert using algorithm
    point = CGPoint(x:(point.x - point.y), y: ((point.x + point.y) / 2))

    //invert y post conversion
    if (!inverse) {
      point = point * CGPoint(x:1, y:-1)
    } else {
      point = point * CGPoint(x:1, y:-1)
    }

    return point

  }

  func placeTileIso(image:String, withPosition:CGPoint, withId id: String) {
    let tileSprite = SKSpriteNode(imageNamed: image)
    tileSprite.position = withPosition
    tileSprite.anchorPoint = CGPoint(x:0, y:0)
    tileSprite.name = id
//    tileSprite.userInteractionEnabled = true
    viewIso.addChild(tileSprite)
  }

  func placeAllTilesIso() {
    for i in 0..<tiles.count {
      let row = tiles[i];
      for j in 0..<row.count {
        var tileInt = row[j]
        if (tileInt > 1) {
          tileInt = 1
        }

        let tile = Tile(rawValue: tileInt)!

        if (tileInt > 0) {
          let index = tileSize.height

                let xxx = ((j*tileSize.width) + index * 0)
                let yyy = -(i*tileSize.height + index  * 0)

                let pointxxx = point2DToIso(CGPoint(x: xxx, y: yyy), inverse: false)
                placeTileIso(("iso_" + tile.image), withPosition:pointxxx, withId: String(row[j]))



          if (row[j] > 1) {

            if (j > 0 || i > 0) {
                for indexs in (0..<row[j]){
                    let xx = ((j*tileSize.width) + index * (-indexs))
                    let yy = -(i*tileSize.height + index  * (-indexs ))

                    let pointxx = point2DToIso(CGPoint(x: xx, y: yy), inverse: false)
                    placeTileIso(("iso_" + tile.image), withPosition:pointxx, withId: String(row[j]))
                }
            } else {
                for indexs in (1..<row[j]) {
                    let xx = -((j*tileSize.width) + index * indexs)
                    let yy = (i*tileSize.height + index  * indexs)

                    print("index = \(0) height: \(row[j]) xx: \(xx) yy: \(yy)")

                    let pointxx = point2DToIso(CGPoint(x: xx, y: yy), inverse: false)
                    placeTileIso(("iso_" + tile.image), withPosition:pointxx, withId: String(row[j]))
                }
            }
          }
        } else {
          let xxx = ((j*tileSize.width) + tileSize.height * 0)
          let yyy = -(i*tileSize.height + tileSize.height  * 0)

          print("index = \(0) height: \(row[j]) xxx: \(xxx) yyy: \(yyy)")

          let pointxxx = point2DToIso(CGPoint(x: xxx, y: yyy), inverse: false)
          placeTileIso(("iso_" + tile.image), withPosition:pointxxx, withId: String(row[j]))
        }
        }
    }
  }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))

            if let name = nodeAtTouch.name {
                if let number = Int(name) {
                    print(number)

                    nodeAtTouch.hidden = true
                }
            }
        }
    }

  func onPinchStart( centroid: CGPoint, scale: CGFloat ) {
    _scaleOffset = viewIso.xScale
  }

  func onPinchMove( centroid: CGPoint, scale: CGFloat ) {
    viewIso.xScale = (scale - 1.0) + _scaleOffset
    viewIso.yScale = (scale - 1.0) + _scaleOffset
  }

  func onPan(gestureRecognizer: UIPanGestureRecognizer) {
    let y = -(gestureRecognizer.locationInView(self.view).y - self.view!.frame.height)
    let x = gestureRecognizer.locationInView(self.view).x

    self.viewIso.position = CGPoint(x: x, y: y)
  }

}