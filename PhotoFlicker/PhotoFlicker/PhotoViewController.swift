//
//  PhotoViewController.swift
//  PhotoFlicker
//
//  Created by Aditya Ashok on 27/09/19.
//  Copyright © 2019 Aditya Ashok. All rights reserved.
//

import UIKit

typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())

class ImageCacheLoader {

    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!

    init() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
    }

    func obtainImageWithPath(imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image)
            }
        } else {
            /* You need placeholder image in your assets,
               if you want to display a placeholder to user */
            let placeholder = UIImage (named: "placeholder.jpg")
            DispatchQueue.main.async {
                completionHandler(placeholder!)
            }
            let url: URL! = URL(string: imagePath)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    let img: UIImage! = UIImage(data: data)
                    self.cache.setObject(img, forKey: imagePath as NSString)
                    DispatchQueue.main.async {
                        completionHandler(img)
                    }
                }
            })
            task.resume()
        }
    }
}


class PhotoViewController: UICollectionViewController, UITextFieldDelegate {
  
  private let insets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  private let viewModel = ViewModel()
  private var searches :[SearchResults] = []
  private var photoItems :[PhotoItem] = []
  private let itemsPerRow: CGFloat = 3
  private var currentPage : Int = 0
  private var prevPage : Int = 0
  private var text : String = ""
  var loadMore: Bool = false
 
  private let imageLoader = ImageCacheLoader()
    
    func photo(for indexPath: IndexPath) -> PhotoItem {
      //return searches[indexPath.section].searchResults[indexPath.row]
      return photoItems[indexPath.row]
    }
    
    func initialize(){
        
        self.currentPage = 0
        self.prevPage = 0
        self.searches = []
        photoItems = []
        viewModel.view = self
        viewModel.searches = []
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        initialize()
        text = textField.text!
        viewModel.doSearch(text:text ,page: currentPage) { SearchResults in
            self.searches = SearchResults
            for result in self.searches{
                self.photoItems = self.photoItems + result.searchResults
            }
            
            DispatchQueue.main.async {
             self.collectionView.reloadData()
            }
            textField.text = ""
        }
      return true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
      return photoItems.count
    }
    
   
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell",
                                                      for: indexPath) as! PhotoCell
        let flickrPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.orange.cgColor
        cell.imageView.image = UIImage (named: "placeholder.jpg")
        
        if let url = flickrPhoto.flickrImageURL(){
            
            imageLoader.obtainImageWithPath(imagePath: url.absoluteString) { (image) in
               
                if let updateCell = collectionView.cellForItem(at: indexPath)  as? PhotoCell{
                    updateCell.imageView.image = image
                }
            }
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            loadMorePhotos()
        }
        else{
            let flickrPhoto = photo(for: indexPath)
            (cell as! PhotoCell).imageView.image = UIImage (named: "placeholder.jpg")
            
            if let url = flickrPhoto.flickrImageURL(){
                
                imageLoader.obtainImageWithPath(imagePath: url.absoluteString) { (image) in
                    
                    if let updateCell = collectionView.cellForItem(at: indexPath)  as? PhotoCell{
                        updateCell.imageView.image = image
                    }
                }
            }
        }
        
    }
    
    func loadMorePhotos() -> Void {
        
        let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
        serialQueue.sync {
            
            currentPage = currentPage + 1
            if currentPage != prevPage {
                var items :[PhotoItem] = []
                prevPage = currentPage
                loadMore = true
                viewModel.doSearch(text: text ,page: currentPage) { SearchResults in
                    self.searches = SearchResults
                    for result in self.searches{
                        items = items + result.searchResults
                    }
                    DispatchQueue.main.async {
                        self.photoItems = items
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func clearTable(_ sender: Any) {
    
        print("Clearing list")
        searches = []
        photoItems = []
        collectionView.reloadData()
    
    }
    
    func downloadImage(flickrPhoto:PhotoItem, cell:PhotoCell ){
        
         DispatchQueue.main.async {
             if let url = flickrPhoto.flickrImageURL(){
                 if let imageData = try? Data(contentsOf: url as URL){
                     if let image = UIImage(data: imageData) {
                         DispatchQueue.main.async {
                             cell.imageView.image = image
                         }
                     }
                 }
             }
         }
    }
}

extension PhotoViewController : UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let space = insets.left * (itemsPerRow + 1)
    let widthAll = view.frame.width - space
    let perItem = widthAll / itemsPerRow
    
    return CGSize(width: perItem, height: perItem)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return insets
  }
    
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 20
  }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.collectionView .reloadData()
    }
    
    
}
