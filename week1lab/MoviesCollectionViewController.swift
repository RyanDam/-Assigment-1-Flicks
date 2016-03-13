//
//  MoviesCollectionViewController.swift
//  week1lab
//
//  Created by Dam Vu Duy on 3/8/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftLoader

enum MainLayout {
    case List
    case Grid
}

class MoviesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    var dataModeString: String = "now_playing"
    
    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataDictionary: NSDictionary?
    
    let refreshControlCollection = UIRefreshControl()
    let refreshControlTable = UIRefreshControl()
    
    let segmentControl = UISegmentedControl(items: ["List", "Gird"])
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.hidden = true
        collectionView.hidden = true
        
        segmentControl.tintColor = UIColor.orangeColor()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: "onSegmentIndexChange:", forControlEvents: .ValueChanged);
        self.navigationItem.titleView = segmentControl
        
        searchBar.placeholder = "Search"
//        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.tintColor = UIColor.orangeColor()
//        self.navigationItem.titleView = searchBar
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.orangeColor()
        
        
        
        refreshControlCollection.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControlCollection, atIndex: 0)
        refreshControlTable.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTable, atIndex: 0)
        
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchPosts(fetchPostOK) { (err) -> Void in
            print(err)
            self.showErrorIndicator()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    // MARK: Navigator
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let targetDetailView = segue.destinationViewController as! MovieDetailViewController
        if isSearching {
            if !tableView.hidden {
                let index = tableView.indexPathForCell(sender as! MovieTableCell)
                targetDetailView.data = fillterData[(index?.row)!]
            }
            else {
                let index = collectionView.indexPathForCell(sender as! MovieCollectionCell)
                targetDetailView.data = fillterData[(index?.row)!]
            }
        }
        else {
            if let data = dataDictionary {
                var index = 0
                if segue.identifier == "CollectionCellSelection" {
                    index = (collectionView.indexPathForCell(sender as! MovieCollectionCell)?.row)!
                    
                }
                else if segue.identifier == "TableCellSelection" {
                    index = (tableView.indexPathForCell(sender as! MovieTableCell)?.row)!
                }
                let tempItem = FillterItem(title: Utils.getFilmTitle(data, row: index), description: Utils.getFilmDescription(data, row: index), imageUrl: Utils.getFilmImageUrl(data, row: index, qualityMode: .Medium), populer: Utils.getFilmPopular(data, row: index), rating: Utils.getFilmRating(data, row: index))
                targetDetailView.data = tempItem
            }
        }
        
    }
    
    // MARK: Collection data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return fillterData.count
        }
        else if let data = dataDictionary {
            return (data["results"]?.count)!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return fillterData.count
        }
        else if let data = dataDictionary {
            return (data["results"]?.count)!
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
        var title = ""
        var description = ""
        var imageUrl = ""
        
        if isSearching {
            title = fillterData[indexPath.row].title
            description = fillterData[indexPath.row].description
            imageUrl = fillterData[indexPath.row].imageUrl
        }
        else {
            title = Utils.getFilmTitle(dataDictionary, row: indexPath.row)
            description = Utils.getFilmDescription(dataDictionary, row: indexPath.row)
            imageUrl = Utils.getFilmImageUrl(dataDictionary, row: indexPath.row, qualityMode: .Medium)
        }
        
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description
        
        cell.thumbnailImage.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl)!), placeholderImage: UIImage(), success: { (request, response, image) -> Void in
            if response != nil {
                cell.thumbnailImage.alpha = 0.0
                cell.thumbnailImage.image = image
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    cell.thumbnailImage.alpha = 1.0
                })
            }
            else {
                cell.thumbnailImage.image = image
            }
            }) { (request, response, err) -> Void in
                print(err)
        }

        
        cell.rowIndex = indexPath.row
        cell.layer.cornerRadius = 6
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! MovieTableCell
        
        var title = ""
        var description = ""
        var imageUrl = ""
        
        if isSearching {
            title = fillterData[indexPath.row].title
            description = fillterData[indexPath.row].description
            imageUrl = fillterData[indexPath.row].imageUrl
        }
        else {
            title = Utils.getFilmTitle(dataDictionary, row: indexPath.row)
            description = Utils.getFilmDescription(dataDictionary, row: indexPath.row)
            imageUrl = Utils.getFilmImageUrl(dataDictionary, row: indexPath.row, qualityMode: .Medium)
        }
        
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description
        
        cell.thumbnailImage.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl)!), placeholderImage: UIImage(), success: { (request, response, image) -> Void in
            if response != nil {
                cell.thumbnailImage.alpha = 0.0
                cell.thumbnailImage.image = image
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    cell.thumbnailImage.alpha = 1.0
                })
            }
            else {
                cell.thumbnailImage.image = image
            }
            }) { (request, response, err) -> Void in
                print(err)
        }
        
        cell.rowIndex = indexPath.row
        
        return cell
        
    }
    
    // MARK: Collection delegate
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        //print("selected item \(indexPath.row):\(indexPath.section)")
        return true
    }
    
    // MARK: Networking
    
    func fetchPosts(successCallback: (NSDictionary) -> Void, errorCallback: ((NSError?) -> Void)?) {
        
        if Utils.isConnectedToNetwork() == false {
            showErrorIndicator()
            return
        }
        
        let clientId = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(dataModeString)?api_key=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        hideErrorIndicator()
        showWaitingIndicate()
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                if let requestError = errorOrNil {
                    errorCallback?(requestError)
                } else {
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                successCallback(responseDictionary)
                        }
                    }
                }
        });
        task.resume()
    }
    
    func fetchPostOK(resultDic: NSDictionary) {
        dataDictionary = resultDic
        collectionView.reloadData()
        tableView.reloadData()
        hideWatingIndicate()
    }
    
    func showWaitingIndicate() {
        SwiftLoader.show(title: "Loading...", animated: true)
    }
    
    func hideWatingIndicate() {
        SwiftLoader.hide()
        if refreshControlCollection.refreshing {
            refreshControlCollection.endRefreshing()
        }
        if refreshControlTable.refreshing {
            refreshControlTable.endRefreshing()
        }
    }
    
    func showErrorIndicator() {
        hideWatingIndicate()
        errorView.hidden = false
    }
    
    func hideErrorIndicator() {
        errorView.hidden = true
    }
    
    // MARK: Action handler
    
    var currentMainLayout = MainLayout.Grid
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        hideErrorIndicator()
        fetchPosts(fetchPostOK) { (err) -> Void in
            print(err)
            self.showErrorIndicator()
        }
    }
    
    func onSegmentIndexChange(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            // list
            collectionView.hidden = true
            tableView.hidden = false
            break
        case 1:
            // grid
            tableView.hidden = true
            collectionView.hidden = false
            break
        default: break
            // nothing :)
        }
    }
    
    // MARK: Search bar handler
    
    var isSearching = false
    
    var fillterData: [FillterItem] = []
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fillterData.removeAll()
        if let data = dataDictionary {
            for i in 0..<(data["results"]?.count)! {
                let title = Utils.getFilmTitle(dataDictionary, row: i)
                if title.lowercaseString.containsString(searchText.lowercaseString) {
                    let tempItem = FillterItem(title: title, description: Utils.getFilmDescription(data, row: i), imageUrl: Utils.getFilmImageUrl(data, row: i, qualityMode: .Medium), populer: Utils.getFilmPopular(data, row: i), rating: Utils.getFilmRating(data, row: i))
                    fillterData.insert(tempItem, atIndex: 0)
                }
            }
        }
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    @IBAction func searchButtonClick(sender: UIBarButtonItem) {
        if isSearching {
            isSearching = false
            searchBar.endEditing(true)
            searchBar.text = ""
            self.navigationItem.titleView = segmentControl
            collectionView.reloadData()
            tableView.reloadData()
        }
        else {
            isSearching = true
            self.navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
        }
    }
    
}

