//
//  ArrayUtils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension CollectionType {
    
    func chunk(withDistance distance: Index.Distance) -> [[SubSequence.Generator.Element]] {
        var index = startIndex
        let generator: AnyGenerator<Array<SubSequence.Generator.Element>> = AnyGenerator {
            defer { index = index.advancedBy(distance, limit: self.endIndex) }
            return index != self.endIndex ? Array(self[index ..< index.advancedBy(distance, limit: self.endIndex)]) : nil
        }
        return Array(generator)
    }
    
}
