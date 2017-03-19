//
//  ArticleConstants.swift
//  snippet
//
//  Created by Dandre Ealy on 3/16/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation

struct ArticleConstants {
    
    
    struct Articles {
        static let apiScheme = "https"
        static let apiHost = "newsapi.org"
        static let apiPath = "/v1/articles"
    }
    
    struct ArticleParameterKeys  {
        static let apiKey = "apiKey"
        static let source = "source"
    }
    
    struct ArticleParameterValues {
        static let apiKey = "c10181507778444a8e0ebc9a0268faf3"
        static let source = ""
    }
    
}
