//
//  PhotoItem.swift
//  PhotoItem
//
//  Created by Aditya Ashok on 27/09/19.
//  Copyright © 2019 Aditya Ashok. All rights reserved.
//


import UIKit


enum Error: Swift.Error {
  case invalidURL
  case noData
}


class PhotoItem: NSObject {
  var thumbnail: UIImage?
  let photoID: String
  let farm: Int
  let server: String
  let secret: String
  
  init (photoID: String, farm: Int, server: String, secret: String) {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
  func flickrImageURL(_ size: String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
      return url
    }
    return nil
  }
    
  func sizeToFillWidth(of size:CGSize) -> CGSize {
    guard let thumbnail = thumbnail else {
      return size
    }
    
    let imageSize = thumbnail.size
    var returnSize = size
    
    let aspectRatio = imageSize.width / imageSize.height
    
    returnSize.height = returnSize.width / aspectRatio
    
    if returnSize.height > size.height {
      returnSize.height = size.height
      returnSize.width = size.height * aspectRatio
    }
    
    return returnSize
  }
  
  static func ==(lhs: PhotoItem, rhs: PhotoItem) -> Bool {
    return lhs.photoID == rhs.photoID
  }
}
