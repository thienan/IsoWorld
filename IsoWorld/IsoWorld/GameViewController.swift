import UIKit
import SpriteKit
import SwiftyJSON

class GameViewController: UIViewController {

  var scene = MenuScene()


  override func viewDidLoad() {
    super.viewDidLoad()

    let skView = self.view as? SKView
    scene.size = skView!.bounds.size
    scene.scaleMode = .AspectFill
    skView!.presentScene(scene)
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

}
