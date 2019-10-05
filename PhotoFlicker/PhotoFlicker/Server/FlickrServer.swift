//
//  AppDelegate.swift
//  FlickrServer
//
//  Created by Aditya Ashok on 27/09/19.
//  Copyright © 2019 Aditya Ashok. All rights reserved.
//

	
import UIKit

struct SearchResults {
    
  let searchTerm : String
  let page : Int
  var searchResults : [PhotoItem]
}

//Flikr Key
let key = "dd94869f3d021116de088d6d709ae6f2"

class FlickrServer {

    //Enum for succcess and fail cases
    enum Result<ResultType> {
      case results(ResultType)
      case error
    }


    //Search using term and page_no
    func searchFlickr(for searchTerm: String, page:Int, completion:
    
        @escaping (Result<SearchResults>) -> Void) {
        
        guard let searchURL = searchImage(for: searchTerm,page: page) else {
            fatalError("Flickr Server : Error while searching")
        }
        
        let request = URLRequest(url: searchURL)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(Result.error)
                }
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data
                else {
                    DispatchQueue.main.async {
                        completion(Result.error)
                    }
                    return
            }
            
            do {
                guard
                    let results = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                    let stat = results["stat"] as? String
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error)
                        }
                        return
                }
                
                if stat == "ok"{
                    print("Success")
                }
                else{
                    DispatchQueue.main.async {
                        completion(Result.error)
                    }
                }
                
                guard
                    let photosContainer = results["photos"] as? [String: AnyObject],
                    let photosReceived = photosContainer["photo"] as? [[String: AnyObject]]
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error)
                        }
                        return
                }
                
                let flickrPhotos: [PhotoItem] = photosReceived.compactMap { photoObject in
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String
                        else {
                            return nil
                    }
                    
                    let flickrPhoto = PhotoItem(photoID: photoID, farm: farm, server: server, secret: secret)
                    
                    return flickrPhoto
                    
                }
                
                let searchResults = SearchResults(searchTerm: searchTerm, page: page, searchResults: flickrPhotos)
                DispatchQueue.main.async {
                    completion(Result.results(searchResults))
                }
            } catch {
                completion(Result.error)
                return
            }
        }.resume()
    }
  
    //returns final url to search
    private func searchImage(for searchTerm:String, page:Int) -> URL? {
        
        guard let text = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        var per_page = 21
        
        if page >= 1{
            per_page = 6
        }
        
        let pageNO = String(page)
        
        let urlStr = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&text=\(text)&per_page=\(per_page)&page=\(pageNO)&format=json&nojsoncallback=1"
        return URL(string:urlStr)
    }
}
