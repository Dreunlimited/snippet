//
//  Constants.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation

struct Constants {
    
    
    struct Sources {
        static let APIScheme = "https"
        static let APIHost = "newsapi.org"
        static let APIPath = "/v1/sources"
    }
    
    struct SourcesParameterKeys  {
        static let category = "category"
        static let language = "language"
        static let country = "country"
    }
    
    struct SourcesParameterValues {
        static let language = "en"
        static let country =  "us"
    }
    
}
