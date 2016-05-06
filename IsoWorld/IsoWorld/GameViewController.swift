import UIKit
import SpriteKit
import SwiftyJSON

class GameViewController: UIViewController {

  var gameScene: GameScene!

  override func viewDidLoad() {
    super.viewDidLoad()

    let scene = GameScene(size: view.bounds.size)
    let skView = view as? SKView
    skView!.showsFPS = true
    skView!.showsNodeCount = true
    skView!.ignoresSiblingOrder = true
    scene.scaleMode = .ResizeFill

    let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(GameViewController.pinchGesture(_:)))
    recognizer.delaysTouchesBegan = true
    skView!.addGestureRecognizer(recognizer)

    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.onPan(_:)))
    panGestureRecognizer.delaysTouchesBegan = true
    skView!.addGestureRecognizer(panGestureRecognizer)

    skView!.presentScene(scene)

    self.gameScene = scene
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

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

}
