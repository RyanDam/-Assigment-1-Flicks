//
//  SearchFillterItem.swift
//  week1lab
//
//  Created by Dam Vu Duy on 3/12/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import Foundation

class FillterItem {
    var title: String = ""
    var description: String = ""
    var imageUrl: String = ""
    var populer: Double = 0
    var rating: Double = 0.0
    
    init() {
        
    }
    
    convenience init(title: String, description: String, imageUrl: String) {
        self.init()
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }
    
    convenience init(title: String, description: String, imageUrl: String, populer: Double, rating: Double) {
        self.init(title: title, description: description, imageUrl: imageUrl)
        self.populer = populer
        self.rating = rating
    }
    
}