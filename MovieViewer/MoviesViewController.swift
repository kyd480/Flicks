//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Kevin Duong on 1/20/16.
//  Copyright © 2016 Kevin Duong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var errorImageView: UIView!
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var endpoint: String!

//    var movieTitles: [String] = []
//    var data: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.blackColor()
//        searchBar.delegate = self

        // clicking on the errorImage will call on imageTapped
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        errorImage.userInteractionEnabled = true
        errorImage.addGestureRecognizer(tapGestureRecognizer)
        
        loadDataFromNetwork()
        
//        data = movieTitles
//        errorImage.hidden = true
        errorImageView.hidden = true
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        
        // Do any additional setup after loading the view.
    }
    
    func imageTapped(img: AnyObject) {
        loadDataFromNetwork()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let movies = movies { // if movies is not nil
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        
        let movie = movies![indexPath.row]
//        let title = movie["title"] as! String
//        let overview = movie["overview"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            cell.posterImage.setImageWithURL(imageURL!)
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterImage.image = nil
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = backgroundView
        
        
        cell.titleLabel = title
        
//        print("\(indexPath.row)")
//        movieTitles[indexPath.row] = title
//        movieTitles.append(title)
//        print(movieTitles)
//        cell.overviewLabel.text = overview
        
        
        return cell
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        movieTitles = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
//            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
//        })
//        
//    }
    
/**    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            movieTitles = data
            print(movieTitles)
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            print(movieTitles)
            movieTitles = data.filter({(dataItem: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    } */
    
    func loadDataFromNetwork() {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                // ... Remainder of response handling code ...
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
//                            self.errorImage.hidden = true
                            self.errorImageView.hidden = true
                    }
                }
                else {
//                    self.errorImage.hidden = false
                    self.errorImageView.hidden = false
                }
                
        });
        task.resume()
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // ... Use the new data to update the data source ...
                
                // ... Remainder of response handling code ...
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
//                            self.errorImage.hidden = true
                            self.errorImageView.hidden = true
                    }
                }
                else {
//                    self.errorImage.hidden = false
                    self.errorImageView.hidden = true
                }
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailedViewController = segue.destinationViewController as! DetailViewController
        
        detailedViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    

}
