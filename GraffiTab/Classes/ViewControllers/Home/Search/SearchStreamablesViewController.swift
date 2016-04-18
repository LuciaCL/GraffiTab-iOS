//
//  SearchStreamablesViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class SearchStreamablesViewController: GridStreamablesViewController {
    
    var searchQuery: String?
    
    func search(query: String) {
        searchQuery = query
        
        refresh()
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        if searchQuery == nil || searchQuery?.characters.count <= 0 {
            GTStreamableManager.getPopular(offset, successBlock: successBlock, failureBlock: failureBlock)
        }
        else {
            GTStreamableManager.searchForHashtag(searchQuery!, offset: offset, successBlock: successBlock, failureBlock: failureBlock)
        }
    }
}
