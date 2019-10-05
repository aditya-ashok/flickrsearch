# flickrsearch

Use flickr search to download and display image in Collection view (swift)

### Xcode 11 Support

1. Flicker API to make a search


Scroll will fetch more results from the Flickr server.


Photo model class corresponding to Flicker JSON Response

  let photoID: String
  let farm: Int
  let server: String
  let secret: String
  var thumbnail: UIImage?
  
Flickr Search Api

https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&
format=json&nojsoncallback=1&safe_search=1&text=kittens

It returns a JSON object with a list of Flickr photo models. The text parameter should be
replaced with the query that the user enters into the app. Each Flickr photo model is defined
as below:
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
