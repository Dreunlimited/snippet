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
        static let apiScheme = "https"
        static let apiHost = "newsapi.org"
        static let apiPath = "/v1/sources"
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
