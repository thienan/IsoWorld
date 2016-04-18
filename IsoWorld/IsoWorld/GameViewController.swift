import UIKit
import SpriteKit

class GameViewController: UIViewController {

  var gameScene: GameScene!

  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .ResizeFill

    let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(GameViewController.pinchGesture(_:)))
    recognizer.delaysTouchesBegan = true
    skView.addGestureRecognizer(recognizer);

    skView.presentScene(scene)

    self.gameScene = scene
  }

  func pinchGesture(gestureRecognizer: UIPinchGestureRecognizer) {
    let scale = gestureRecognizer.scale
    let centroid = gestureRecognizer.locationInView( self.view )

    switch gestureRecognizer.state {
    case .Began:
      self.gameScene.onPinchStart( centroid, scale: scale )

    default:
      self.gameScene.onPinchMove( centroid, scale: scale )
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}