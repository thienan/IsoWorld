//: Playground - noun: a place where people can play

import Foundation
import GameplayKit
import SpriteKit

let MAX : UInt32 = 100
let MIN : UInt32 = 1

func randomNumber() -> Int {
    return Int(arc4random_uniform(MAX) + MIN)
}

var randomNumbers = [Int]()

for index in 1...100 {
    randomNumbers.append(randomNumber() / 10)
}

let array = randomNumbers.sort()

var reversedSorted = [Int]()

for (index, item) in array.reverse().enumerate() {
  reversedSorted.append(item)
}

let coumns = Int(round(sqrt(Double(reversedSorted.count))))

var arrayx = Array<Array<Int>>()
for column in 0..<coumns {
  arrayx.append(Array(count:coumns, repeatedValue:Int()))
}

var index = 0

for i in (0..<coumns) {
    for j in (0..<i + 1) {
        arrayx[i - j][j] = reversedSorted[index]
        index += 1
    }
}

for i in (1..<coumns) {
    for j in (i..<coumns) {
            if (reversedSorted.indices.contains(index)) {
                arrayx[coumns - j + i - 1][j] = reversedSorted[index]
                index += 1
            } else {
                arrayx[coumns - j + i - 1][j] = 0
            }

    }
}

print(arrayx)

var arr = [[Int](arrayLiteral: coumns * 2)]

for i in (0..<arrayx.count) {
    for j in (0..<arrayx.count) {
        if (j > arrayx[i].count) {
            arr[i][j] = arrayx[i][j]
        }
    }
}

print(arr)
