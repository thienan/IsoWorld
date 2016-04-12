//: Playground - noun: a place where people can play

import SpriteKit
import XCPlayground

//Create the SpriteKit View
let view:SKView = SKView(frame: CGRectMake(0, 0, 1024, 768))

//Add it to the TimeLine
XCPlaygroundPage.currentPage.liveView = view

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

  //1
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //2
  let view2D:SKSpriteNode
  let viewIso:SKSpriteNode

  //3
  let tiles = [
    [1, 0, 1, 0, 1, 0, 0],
    [0 ,0, 0, 0, 0, 0, 0],
    [1 ,0, 1, 0, 1, 0, 0],
    [0 ,0, 0, 0, 0, 0, 0],
    [1 ,0, 1, 0, 1, 0, 0]
  ]
  let tileSize = (width:32, height:32)

  //4
  override init(size: CGSize) {

    view2D = SKSpriteNode()
    viewIso = SKSpriteNode()

    super.init(size: size)
    self.anchorPoint = CGPoint(x:0.5, y:0.5)
  }

  //5
  override func didMoveToView(view: SKView) {

    let deviceScale = self.size.width/667

    view2D.position = CGPoint(x:-self.size.width*0.45, y:self.size.height*0.17)
    view2D.xScale = deviceScale
    view2D.yScale = deviceScale
    addChild(view2D)

    viewIso.position = CGPoint(x:self.size.width*0.12, y:self.size.height*0.12)
    viewIso.xScale = deviceScale
    viewIso.yScale = deviceScale
    addChild(viewIso)

    placeAllTiles2D()
    placeAllTilesIso()
  }

  func placeTile2D(image:String, withPosition:CGPoint) {

    let tileSprite = SKSpriteNode(imageNamed: image)

    tileSprite.position = withPosition

    tileSprite.anchorPoint = CGPoint(x:0, y:0)

    view2D.addChild(tileSprite)

  }

  func placeAllTiles2D() {

    for i in 0..<tiles.count {

      let row = tiles[i];

      for j in 0..<row.count {
        let tileInt = row[j]

        //1
        let tile = Tile(rawValue: tileInt)!

        //2
        let point = CGPoint(x: (j*tileSize.width), y: -(i*tileSize.height))

        placeTile2D(tile.image, withPosition:point)
      }

    }

  }

  func point2DToIso(p:CGPoint) -> CGPoint {

    //invert y pre conversion
    var point = p * CGPoint(x:1, y:-1)

    //convert using algorithm
    point = CGPoint(x:(point.x - point.y), y: ((point.x + point.y) / 2))

    //invert y post conversion
    point = point * CGPoint(x:1, y:-1)

    return point

  }

  func pointIsoTo2D(p:CGPoint) -> CGPoint {

    //invert y pre conversion
    var point = p * CGPoint(x:1, y:-1)

    //convert using algorithm
    point = CGPoint(x:((2 * point.y + point.x) / 2), y: ((2 * point.y - point.x) / 2))

    //invert y post conversion
    point = point * CGPoint(x:1, y:-1)

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
        let tileInt = row[j]

        let tile = Tile(rawValue: tileInt)!

        if (tile.rawValue == Tile.Wall.rawValue) {

          //1
          let pointx = point2DToIso(CGPoint(x: (j*tileSize.width) + tileSize.height * 2, y: -(i*tileSize.height + tileSize.height * 2)))

          //2
          placeTileIso(("iso_"+tile.image), withPosition:pointx)

          //1
          let point = point2DToIso(CGPoint(x: (j*tileSize.width) + tileSize.height, y: -(i*tileSize.height + tileSize.height)))

          //2
          placeTileIso(("iso_"+tile.image), withPosition:point)

          //1
          let pointy = point2DToIso(CGPoint(x: (j*tileSize.width), y: -(i*tileSize.height)))

          //2
          placeTileIso(("iso_"+tile.image), withPosition:pointy)

        } else {
          
          //1
          let pointx = point2DToIso(CGPoint(x: (j*tileSize.width) + tileSize.height * 2, y: -(i*tileSize.height + tileSize.height * 2)))
          
          //2
          placeTileIso(("iso_"+tile.image), withPosition:pointx)
        }
      }
    }
  }
}

//Create the scene and add it to the view
let scene:SKScene = GameScene(size: CGSizeMake(1024, 2048))
scene.scaleMode = SKSceneScaleMode.AspectFit
view.presentScene(scene)
