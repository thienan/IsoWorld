import UIKit
import SpriteKit

class GameViewController: UIViewController {
  private let userService = UserService()
  
  override func viewDidLoad() {
    let userService = UserService()
    super.viewDidLoad()
    let scene = MenuScene()
    let skView = self.view as? SKView
    scene.size = skView!.bounds.size
    scene.scaleMode = .AspectFill
    scene.rootController = self
    skView!.presentScene(scene)

    userService.loadUserRating()
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

}
