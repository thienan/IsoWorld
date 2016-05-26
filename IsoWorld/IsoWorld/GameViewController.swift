import UIKit
import SpriteKit

class GameViewController: UIViewController {
  let userService = UserService()


  override func viewDidLoad() {

    super.viewDidLoad()
    let scene = MenuScene()
    let skView = self.view as? SKView
    scene.size = skView!.bounds.size
    scene.scaleMode = .AspectFill
    scene.controller = self
    skView!.presentScene(scene)
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

}
