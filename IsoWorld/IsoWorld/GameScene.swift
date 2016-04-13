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

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let viewIso:SKSpriteNode

  let tiles = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 2, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
  ]

  let tileSize = (width:32, height:32)

  override init(size: CGSize) {
    viewIso = SKSpriteNode()
    super.init(size: size)
  }


  override func didMoveToView(view: SKView) {

    let deviceScale = self.size.width/667

    viewIso.position = CGPoint(x: 100, y: 100)
    viewIso.xScale = deviceScale
    viewIso.yScale = deviceScale
    addChild(viewIso)

    placeAllTilesIso()
  }


  func point2DToIso(p:CGPoint) -> CGPoint {

    //invert y pre conversion
    var point = p * CGPoint(x:-1, y:1)

    //convert using algorithm
    point = CGPoint(x:(point.x - point.y), y: ((point.x + point.y) / 2))

    //invert y post conversion
    point = point * CGPoint(x:-1, y:1)

    return point

  }

  func placeTileIso(image:String, withPosition:CGPoint) {
    let tileSprite = SKSpriteNode(imageNamed: image)
    tileSprite.position = withPosition
    tileSprite.anchorPoint = CGPoint(x:0, y:0)
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

//        let tile = Tile(rawValue: tileInt)!

        if (tileInt > 0) {
          let index = tileSize.height

//          let xxx = -((j*tileSize.width) + index * 3)
//          let yyy = (i*tileSize.height + index  * 3)
//
//          print("index = \(0) height: \(row[j]) xxx: \(xxx) yyy: \(yyy)")
//
//          let pointxxx = point2DToIso(CGPoint(x: xxx, y: yyy))
//          placeTileIso(("iso_wall"), withPosition:pointxxx)
//
//          let xx = -((j*tileSize.width) + index * 2)
//          let yy = (i*tileSize.height + index  * 2)
//
//          print("index = \(0) height: \(row[j]) xx: \(xx) yy: \(yy)")
//
//          let pointxx = point2DToIso(CGPoint(x: xx, y: yy))
//          placeTileIso(("iso_wall"), withPosition:pointxx)


          let x = ((j*tileSize.width) + index * 0)
          let y = -(i*tileSize.height + index  * 0)
          print("index = \(0) height: \(row[j]) x: \(x) y: \(y)")

          let pointx = point2DToIso(CGPoint(x: x, y: y))
          placeTileIso(("iso_wall"), withPosition:pointx)

          if (row[j] > 1) {

//            for indexs in (1..<row[j]) {
//              let xx = -((j*tileSize.width) + index * indexs)
//              let yy = (i*tileSize.height + index  * indexs)
//
//              print("index = \(0) height: \(row[j]) xx: \(xx) yy: \(yy)")
//
//              let pointxx = point2DToIso(CGPoint(x: xx, y: yy))
//              placeTileIso(("iso_wall"), withPosition:pointxx)
//            }



//            let xxx = -((j*tileSize.width) + index * 2)
//            let yyy = (i*tileSize.height + index  * 2)
//
//            print("index = \(0) height: \(row[j]) xx: \(xx) yy: \(yy)")
//
//            let pointxxx = point2DToIso(CGPoint(x: xxx, y: yyy))
//            placeTileIso(("iso_wall"), withPosition:pointxxx)
          }
        }


        }
    }
  }
}