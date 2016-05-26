//
//  MenuScene.swift
//  LightFlow
//
//  Created by rmuhamedgaliev on 13/03/16.
//  Copyright © 2016 rmuhamedgaliev. All rights reserved.
//

import SpriteKit
import FBSDKLoginKit
import FirebaseAuth

class MenuScene: SKScene {
  var logoNode: SKSpriteNode?
  var gameLabel: SKLabelNode?
  var ratingLabel: SKLabelNode?
  var facebokLogin: SKSpriteNode?
  
  var controller: UIViewController?

  var gameScene: Rating!

  let userService = UserService()

  override func didMoveToView(view: SKView) {

    self.backgroundColor = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1)

    addLogo()
    addNewGameTitle()
    addRatingTitle()
    addFacebookButton()
  }

  private func addLogo() {
    let size = CGSize(width: 250, height: 250)
    self.logoNode = SKSpriteNode(imageNamed: "logo")
    self.logoNode?.size = size
    self.logoNode?.position = CGPoint(
      x: CGRectGetMidX((self.scene?.frame)!),
      y: CGRectGetHeight((self.scene?.frame)!) - 200
    )
    self.addChild(self.logoNode!)
  }

  private func addNewGameTitle() {
    self.gameLabel = SKLabelNode()
    self.gameLabel?.fontSize = 36
    self.gameLabel?.fontColor = UIColor.whiteColor()
    self.gameLabel?.text = "GAME".localized
    self.gameLabel?.name = "game"
    self.gameLabel?.fontName = "Cinzel-Regular"
    self.gameLabel?.position = CGPoint(x: CGRectGetMidX((self.scene?.frame)!), y: CGRectGetMidY((self.scene?.frame)!) - 50)
    self.addChild(gameLabel!)
  }

  private func addRatingTitle() {
    self.ratingLabel = SKLabelNode()
    self.ratingLabel?.fontSize = 36
    self.ratingLabel?.fontColor = UIColor.whiteColor()
    self.ratingLabel?.text = "RATING".localized
    self.ratingLabel?.name = "rating"
    self.ratingLabel?.fontName = "Cinzel-Regular"
    self.ratingLabel?.position = CGPoint(x: CGRectGetMidX((self.scene?.frame)!), y: CGRectGetMidY((self.scene?.frame)!) - 100)
    self.addChild(ratingLabel!)
  }

  private func addFacebookButton() {
    let size = CGSize(width: (self.scene?.size.width)!, height: 50)
    self.facebokLogin = SKSpriteNode(imageNamed: "facebook_login")
    self.facebokLogin?.size = size
    self.facebokLogin?.position = CGPoint(
      x: size.width / 2,
      y: 25
    )
    self.facebokLogin?.name = "facebook"
    self.addChild(self.facebokLogin!)
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.menuHelper(touches)
  }

  private func menuHelper(touches: Set<UITouch>) {
    for touch in touches {
      let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))
      if nodeAtTouch.name == "game" {
        let scene = GameScene(size: CGSizeMake(DefinedScreenWidth, DefinedScreenHeight))

        // Configure the view.
        let skView = self.view
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView!.ignoresSiblingOrder = true

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill

        skView!.presentScene(scene)
      } else if nodeAtTouch.name == "rating" {

        let scene = Rating(size: view!.bounds.size)
        let skView = self.view
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = (skView?.bounds.size)!

        skView!.presentScene(scene)
        self.gameScene = scene
      } else if nodeAtTouch.name == "facebook" {
        
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount

        loginManager.logInWithReadPermissions(
          ["basic_info", "public_profile", "email", "user_friends"],
          fromViewController: controller,
          handler: {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
              FBSDKLoginManager().logOut()
            } else if result.isCancelled {
              FBSDKLoginManager().logOut()
            } else {
              if FBSDKAccessToken.currentAccessToken() != nil {

                FBSDKGraphRequest(
                  graphPath: "me",
                  parameters: ["fields": "id, name, first_name, last_name, email"]
                ).startWithCompletionHandler {(connection, result, error) -> Void in
                  if error == nil {
                    let dict = result as? NSDictionary
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                    FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                      self.userService.saveCurrentUserId(userId: user!.uid)

                      let score = UserScore(name: (dict!["name"] as? String)!, score: 0, time: 0, me: false)
                      self.userService.saveCurrentUserScore(score)
                    }
                  }
                }
              }
            }
        })
      }
    }
  }



}
