//
//  PhotoViewController.swift
//  PhotoFlicker
//
//  Created by Aditya Ashok on 27/09/19.
//  Copyright © 2019 Aditya Ashok. All rights reserved.
//

import UIKit

class PhotoViewController: UICollectionViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextView: UITextField!
    private let insets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let viewModel = ViewModel()
    private var searches :[SearchResults] = []
    private var photoItems :[PhotoItem] = []
    private var itemsPerRow: CGFloat = 3
    private var currentPage : Int = 0
    private var prevPage : Int = 0
    private var text : String = ""
    
    private let imageLoader = ImageCacheLoader()
    
    func photo(for indexPath: IndexPath) -> PhotoItem {
        return photoItems[indexPath.row]
    }
    
    //Setup property (reset)
    func initialize(){
        self.currentPage = 0
        self.prevPage = 0
        self.searches = []
        photoItems = []
        
        if viewModel.view == nil{
            viewModel.view = self
        }
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
            textField.layer.borderColor = UIColor.orange.cgColor
            textField.layer.borderWidth = 2
            textField.placeholder = "Search"
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
    
    //load more when the end of the scroll is reached
    func loadMorePhotos() -> Void {
        
        let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
        serialQueue.sync {
            
            currentPage = currentPage + 1
            if currentPage != prevPage {
                var items :[PhotoItem] = []
                prevPage = currentPage
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
    
    
    //Clear context
    @IBAction func clearTable(_ sender: Any) {
        print("Clearing list")
        searches = []
        photoItems = []
        text = ""
        searchTextView.text = ""
        searchTextView.placeholder = "Search"
        collectionView.reloadData()
        
    }
    
    //donwload and update cell
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

}
