//
//  ViewModel.swift
//  PhotoFlicker
//
//  Created by Aditya Ashok on 04/10/19.
//  Copyright © 2019 Aditya Ashok. All rights reserved.
//

import UIKit

class ViewModel: NSObject {
    
    let photoCell = PhotoCell()
    var server = FlickrServer()
    var view:PhotoViewController!
    
    var searches: [SearchResults] = []
    private let flickr = FlickrServer()

    override init() {
        
    }

    func doSearch(text:String,page:Int, completion:
    @escaping ([SearchResults]) -> Void) {
        
        let indicator = UIActivityIndicatorView(style: .large)
        view.view.addSubview(indicator)
        indicator.frame = view.view.frame
        indicator.startAnimating()
        
        server.searchFlickr(for:text,page: page) { searchResults in
            indicator.removeFromSuperview()
            
            switch searchResults {
            case .error:
                print("Error")
            case .results(let results):
                self.searches.insert(results, at: self.searches.count)
            }
            completion(self.searches)
        }
    }
    
}
