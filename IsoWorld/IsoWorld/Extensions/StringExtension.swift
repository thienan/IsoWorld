//
//  String.swift
//  LightFlow
//
//  Created by rmuhamedgaliev on 18/04/16.
//  Copyright © 2016 rmuhamedgaliev. All rights reserved.
//

import Foundation

extension String {
  var count: Int {
    return self.characters.count
  }

  var localized: String {
    return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
  }
}
