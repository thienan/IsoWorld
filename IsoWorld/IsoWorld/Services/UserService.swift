//
//  RatingService.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/8/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol UserServiceDelegate {
  /**
   Load user scores from data objects

   - returns: array object with scores models
   */
  func loadUserRating() -> [UserScore]

  /**
   Convert vector of UserScore objcts to square matrix

   - parameter vector: source vector

   - returns: <#return value description#>
   */
  func convertUserScoresToMatrix(fromVector vector: [UserScore]) -> [[UserScore]]

  func saveCurrentUserScore(score: UserScore)

  func saveCurrentUserId(userId userId: String)

  func getCurrentUserId() -> String
}

class UserService: UserServiceDelegate {
  private let defaults = NSUserDefaults.standardUserDefaults()

  private struct UserKeys {
    static let userIdKey = "userId"
  }

  func loadUserRating() -> [UserScore] {
    let userRef = FIRDatabase.database().reference().child("user")
    userRef.keepSynced(true)

    var scores = [UserScore]()

    userRef.observeEventType(.Value, withBlock: { data in
      for scoreData in data.children.enumerate() {
        let score = scoreData.element
        let userScore = UserScore(
          name: score.value["name"] as! String,
          score: score.value["score"] as! Int,
          time: score.value["time"] as! Int,
          me: false
        )

        scores.append(userScore)
      }
    })

    scores = scores.sort {$0.score > $1.score}
    return scores
  }

  func convertUserScoresToMatrix(fromVector vector: [UserScore]) -> [[UserScore]] {
    let coumns = (Int(round(sqrt(Double(vector.count)))) + 1) * 2
    var arrayx = Array<Array<UserScore>>()
    for _ in 0..<coumns {
      arrayx.append(Array(count: coumns, repeatedValue: UserScore()))
    }
    var index = 0
    for i in (0..<coumns) {
      for j in (0..<i + 1) {
        if vector.indices.contains(index) {
          arrayx[i - j][j] = vector[index]
        } else {
          arrayx[i - j][j] = UserScore()
        }
        index += 1
      }
    }

    for i in (1..<coumns) {
      for j in (i..<coumns) {
        if vector.indices.contains(index) {
          arrayx[coumns - j + i - 1][j] = vector[index]
          index += 1
        } else {
          arrayx[coumns - j + i - 1][j] = UserScore()
        }
      }
    }
    return arrayx
  }

  func saveCurrentUserScore(score: UserScore) {
    let userRef = FIRDatabase.database().reference().child("user")
    let userId = getCurrentUserId()

    var userDic = [String: AnyObject]()
    userDic["name"] = score.name
    userDic["time"] = score.time
    userDic["score"] = score.score
    userDic["me"] = score.me

    userRef.child(userId).setValue(userDic)
  }

  func saveCurrentUserId(userId userId: String) {
    let userRef = FIRDatabase.database().reference().child("user")
    defaults.setValue(userId, forKey: UserKeys.userIdKey)
    userRef.setValue("")
  }

  func getCurrentUserId() -> String {
    if let userId = defaults.stringForKey(UserKeys.userIdKey) {
      return userId
    } else {
      return ""
    }
  }

}
