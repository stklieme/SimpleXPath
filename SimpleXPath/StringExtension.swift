//
//  StringExtension.swift
//  SimpleXPath
//
//  Created by CHEN Xian’an on 2/21/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

import Foundation
import libxml2

extension String {
  
  var xmlCharPointer: UnsafePointer<xmlChar> {
    return unsafeBitCast((self as NSString).UTF8String, UnsafePointer<xmlChar>.self)
  }
  
  var namespacePrefixs: Set<String>? {
    if let regexp = try? NSRegularExpression(pattern: "(\\w+):[^\\W:]", options: []) {
      let matches = regexp.matchesInString(self, options: [], range: NSMakeRange(0, self.utf16.count))
      return Set(matches.map {
        let range = $0.rangeAtIndex(1)
        return NSString.substringWithRange(self)(range)
      })
    }
  
    return nil
  }

}
