//: Playground - noun: a place where people can play

import Foundation
import GameplayKit

let array = [1, 2, 3, 4, 4, 1, 2, 3, 4, 4, 1, 2, 3, 4, 4, 1, 2, 3, 4, 4, 3].sort()

let arraySize = array.count

extension Array {
  func split() -> [[Element]] {

    let columns = round(Double(self.count) / 2)
    let rows = round(Double(self.count) / columns)

    let ct = self.count
    let half = ct / Int(rows)
    let leftSplit = self[0 ..< half]
    let rightSplit = self[half ..< ct]
    return [Array(leftSplit), Array(rightSplit)]
  }
}

// Split array

let arrays = array.split()

for i in (0 ..< arrays.count) {
  let row = arrays[i]

  for j in (0 ..< row.count) {
    print("\(i,j)")
  }
}

