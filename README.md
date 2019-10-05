# Flickr-Search

Sample code to do a flickr search and display in UICollection view. It asks for a key and it displays the result with endless scrolling.

Inside this project UISearchBar using for type keywords and UICollectionView for display search results in 3 columns. On reaching the end of the scroll, it asks for new images and then displays.

# Getting Started
1. Clone the repo and run Flickr-Search.xcodeproj
2. No pod install required use this projects
3. Support Xcode 11

You need a Flickr Api key to run this porject, one sample key is hardcoded in this project. 
You can replace it with yours. 

# Requirements
Deployment target of your App is >= iOS 10.0
XCode 11
Swift 4.0
Flickr API Documentation
Images are retrieved by hitting the Flickr API.

Search Path:
https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=YOUR_FLICKR_API_KEY&format=json&nojsoncallback=1&safe_search=1&text=KEYWORD
Response includes an array of photo objects, each represented as:
{
    "id": "23451156376",
    "owner": "28017113@N08",
    "secret": "8983a8ebc7",
    "server": "578",
    "farm": 1,
    "title": "Tiger",
}
To load the photo, you can build the full URL following this pattern:
http://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg
Thus, using our Flickr photo model example above, the full URL would be:
http://farm1.static.flickr.com/578/23451156376_8983a8ebc7.jpg
Generate your own here:
https://www.flickr.com/services/api/misc.api_keys.html
Keyword search request
UISearchBar priving for keyword search access.

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        
        //Reset old data first befor new search Results
        resetValuesForNewSearch()
        
        //Requesting here new keyword
        fetchSearchImages()
    }

# Features

1. Image Caching : Download image only when it is not available in cache.

 func obtainImageWithPath(imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        
        //caching image, if not present downloading
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image)
            }
        } else {
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
    
  
  
 2. Image on Demand : Endless scrolling
    
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

3. Search in Navigation bar

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        initialize()
        text = textField.text!
        viewModel.doSearch(text:text ,page: currentPage) {[unowned self] SearchResults in
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


4. Clear search context : Dedicated button in navigation bar to clear the result result.

  @IBAction func clearTable(_ sender: Any) {
        print("Clearing list")
        searches = []
        photoItems = []
        text = ""
        searchTextView.text = ""
        searchTextView.placeholder = "Search"
        collectionView.reloadData()
        
    }

  
👤 Author
Aditya Ashok
