//
//  Product.swift
//  Shopify
//
//  Created by John Peng on 2019-01-07.
//  Copyright © 2019 John Peng. All rights reserved.
//

import Foundation

class Product {
    
    var title: String = ""
    var type: String = ""
    var body_html: String = ""
    var vendor: String = ""
    var url: String = ""
    var id: String = ""
    
    init(atitle: String, atype: String, abody: String, avendor: String, aurl: String, aID: String) {
        title = atitle
        type = "TYPE: \(atype.uppercased())"
        body_html = abody
        vendor = avendor
        url = aurl
        id = aID
    }
    
    init(aid: String) {
        id = aid
    }
    
}
