//
//  Collection.swift
//  Shopify
//
//  Created by John Peng on 2019-01-07.
//  Copyright © 2019 John Peng. All rights reserved.
//

import Foundation

class Collection {
    var title: String;
    var imgURL: String;
    var bodyHTML: String;
    var collectionID: String;
    
    init() {
        title = ""
        imgURL = ""
        bodyHTML = ""
        collectionID = ""
    }
    
    init(aTtitle: String, aURL: String, aBody: String, aID: String) {
        title = aTtitle
        imgURL = aURL
        bodyHTML = aBody
        collectionID = aID
    }
}
