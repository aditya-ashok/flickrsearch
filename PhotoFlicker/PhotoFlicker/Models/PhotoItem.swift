//
//  PhotoItem.swift
//  PhotoItem
//
//  Created by Aditya Ashok on 27/09/19.
//  Copyright © 2019 Aditya Ashok. All rights reserved.
//


import UIKit

//Photo Object Class
class PhotoItem: NSObject {
  
  let photoID: String
  let farm: Int
  let server: String
  let secret: String
  var thumbnail: UIImage?
    
  init (photoID: String, farm: Int, server: String, secret: String) {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
    
  //This returns the url for image
  func flickrImageURL(_ size: String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
      return url
    }
    return nil
  }
}
