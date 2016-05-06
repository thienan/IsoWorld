//
//  UserScore.swift
//  IsoWorld
//
//  Created by rmuhamedgaliev on 06/05/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation
import SpriteKit

class UserNode: SKSpriteNode {

  var userObj: UserScore?

}

class UserScore {
  dynamic var name: String = ""
  dynamic var photo: String = "photo"
  dynamic var score: Int = 0
  dynamic var me: Bool = false

  init() {}

  init(name: String, score: Int, me: Bool) {
    self.name = name
    self.photo = "photo"
    self.score = score
    self.me = me
  }
  
}
