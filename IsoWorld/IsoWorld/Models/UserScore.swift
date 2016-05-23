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
  dynamic var score: Int = 0
  dynamic var me: Bool = false
  dynamic var time: Int = 0

  init() {}

  init(name: String, score: Int, me: Bool) {
    self.name = name
    self.score = score
    self.me = me
  }

  init(fromDictionary dictionary: NSDictionary) {
    if let name = dictionary["name"] as? String {
      self.name = name
    }

    if let score = dictionary["score"] as? Int {
      self.score = score
    }

    if let me = dictionary["me"] as? Bool {
      self.me = me
    }

    if let time = dictionary["time"] as? Int {
      self.time = time
    }
  }

}
