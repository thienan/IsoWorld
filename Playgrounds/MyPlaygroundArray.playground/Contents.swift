//: Playground - noun: a place where people can play

import Foundation
import GameplayKit

let array = [1, 2, 3, 4, 4, 1, 2, 3, 4, 4, 1, 2, 3, 4, 4, 1, 2, 3, 4, 4, 3].sort()

var reversedSorted = [Int]()

for (index, item) in array.reverse().enumerate() {
  reversedSorted.append(item)
}

print(reversedSorted)

let coumns = Int(round(sqrt(Double(reversedSorted.count))))

var arrayx = Array<Array<Int>>()
for column in 0..<coumns {
  arrayx.append(Array(count:coumns, repeatedValue:Int()))
}

var index = 0
for i in (0..<coumns) {
  for j in (0..<coumns) {
    if (reversedSorted.indices.contains(index)) {
      arrayx[i][j] = reversedSorted[index]
      index += 1
    } else {
      arrayx[i][j] = 0
    }
  }
}

arrayx
