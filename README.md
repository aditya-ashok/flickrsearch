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
    "title": "Merry Christmas!",
    "ispublic": 1,
    "isfriend": 0,
    "isfamily": 0
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

Collection View with flowlayout
Image Cache
Generics type Async Network request
 router.requestFor(text: searchBar.text ?? "", with: pageCount.description, decode: { json -> Photos? in
        guard let flickerResult = json as? Photos else { return  nil }
        return flickerResult
 }) { [unowned self] result in
            self.labelLoading.text = ""
            switch result{
            case .success(let value):
                self.updateSearchResult(with: value.photos.photo, nil)
            case .failure(let error):
                print(error.debugDescription)
                self.showAlertWithError((error?.localizedDescription) ??
                "Please check your Internet connection or try again.", completionHandler: {[unowned self] status in
                    guard status else { return }
                    self.fetchSearchImages()
            })
      }
  }
  
  
👤 Author
Aditya Ashok
