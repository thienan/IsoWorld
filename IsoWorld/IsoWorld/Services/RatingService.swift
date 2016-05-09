//
//  RatingService.swift
//  IsoWorld
//
//  Created by Rinat Muhamedgaliev on 5/8/16.
//  Copyright © 2016 Rinat Muhamedgaliev. All rights reserved.
//

import Foundation

protocol UserServiceDelegate {
  /**
   Load user scores from data objects

   - returns: array object with scores models
   */
  func loadUserRating() -> [UserScore]

  func convertUserScoresToMatrix(fromVector vector: [UserScore]) -> [[UserScore]]
}

class UserService: UserServiceDelegate {

  func loadUserRating() -> [UserScore] {

    let plistPath = NSBundle.mainBundle().pathForResource("UserScores", ofType: "plist")
    let scoreArray = NSArray(contentsOfFile: plistPath!)

    var scores = [UserScore]()

    for score in scoreArray! {
      let userScore = UserScore(fromDictionary: score as! NSDictionary)
      scores.append(userScore)
    }

    return scores
  }

  func convertUserScoresToMatrix(fromVector vector: [UserScore]) -> [[UserScore]] {

    let coumns = (Int(round(sqrt(Double(vector.count)))) + 1) * 2

    var arrayx = Array<Array<UserScore>>()

    for column in 0..<coumns {
      arrayx.append(Array(count:coumns, repeatedValue:UserScore()))
    }

    var index = 0

    for i in (0..<coumns) {
      for j in (0..<i + 1) {
        if (vector.indices.contains(index)) {
          arrayx[i - j][j] = vector[index]
        } else {
          arrayx[i - j][j] = UserScore()
        }
        index += 1
      }
    }

    for i in (1..<coumns) {
      for j in (i..<coumns) {
        if (vector.indices.contains(index)) {
          arrayx[coumns - j + i - 1][j] = vector[index]
          index += 1
        } else {
          arrayx[coumns - j + i - 1][j] = UserScore()
        }
        
      }
    }

    return arrayx
  }

}


