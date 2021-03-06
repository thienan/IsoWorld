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
  private var logoNode: SKSpriteNode?
  private var gameLabel: SKLabelNode?
  private var ratingLabel: SKLabelNode?
  private var facebokLoginButton: SKSpriteNode?
  
  var rootController: UIViewController?

  private let userService = UserService()

  override func didMoveToView(view: SKView) {
    self.backgroundColor = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1)
    addLogo()
    addNewGameTitle()
    addRatingTitle()
    addFacebookButton()
    
//    for i in (0...100) {
//      let score = UserScore(name: "User-\(i)", score: randomInRange(0...10), time: randomInRange(1...60), me: false)
//      self.userService.saveUserScore(userId: "\(i)", score: score)
//    }

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
    self.facebokLoginButton = SKSpriteNode(imageNamed: "facebook_login")
    self.facebokLoginButton?.size = size
    self.facebokLoginButton?.position = CGPoint(
      x: size.width / 2,
      y: 25
    )
    self.facebokLoginButton?.name = "facebook"
    self.addChild(self.facebokLoginButton!)
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.menuHelper(touches)
  }

  private func menuHelper(touches: Set<UITouch>) {
    for touch in touches {
      let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))
      if nodeAtTouch.name == "game" {
        let scene = GameScene(size: CGSizeMake(DefinedScreenWidth, DefinedScreenHeight))
        let skView = self.view
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill

        skView!.presentScene(scene)
      } else if nodeAtTouch.name == "rating" {

        let scene = RatingScene(size: view!.bounds.size)
        let skView = self.view
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = (skView?.bounds.size)!

        skView!.presentScene(scene)
      } else if nodeAtTouch.name == "facebook" {
        
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount

        loginManager.logInWithReadPermissions(
          ["basic_info", "public_profile", "email", "user_friends"],
          fromViewController: rootController,
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
                      self.userService.saveCurrentUserName(userName: (dict!["name"] as? String)!)

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
