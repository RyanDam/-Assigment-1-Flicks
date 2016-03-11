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

class MoviesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var dataModeString: String = "now_playing"
    
    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataDictionary: NSDictionary?
    
    let refreshControlCollection = UIRefreshControl()
    let refreshControlTable = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.hidden = true
        collectionView.hidden = true
        
        let items = ["List", "Gird"]
        
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.tintColor = UIColor.orangeColor()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: "onSegmentIndexChange:", forControlEvents: .ValueChanged);
        self.navigationItem.titleView = segmentControl
        
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
        
        if segue.identifier == "CollectionCellSelection" {
            let pressedCell = sender as! MovieCollectionCell
            let targetDetailView = segue.destinationViewController as! MovieDetailViewController
            targetDetailView.dataDictionary = dataDictionary
            targetDetailView.cellRow = pressedCell.rowIndex
        }
        else if segue.identifier == "TableCellSelection" {
            let pressedCell = sender as! MovieTableCell
            let targetDetailView = segue.destinationViewController as! MovieDetailViewController
            targetDetailView.dataDictionary = dataDictionary
            targetDetailView.cellRow = pressedCell.rowIndex
        }
        
    }
    
    // MARK: Collection data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = dataDictionary {
            return (data["results"]?.count)!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = dataDictionary {
            return (data["results"]?.count)!
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
        
        cell.rowIndex = indexPath.row
        cell.titleLabel.text = Utils.getFilmTitle(dataDictionary, row: indexPath.row)
        cell.descriptionLabel.text = Utils.getFilmDescription(dataDictionary, row: indexPath.row)
        cell.thumbnailImage.setImageWithURL(NSURL(string: Utils.getFilmImageUrl(dataDictionary, row: indexPath.row, qualityMode: .Medium))!, placeholderImage: UIImage(named: "defaultCardImage"))
        
        cell.layer.cornerRadius = 6
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! MovieTableCell
        
        cell.rowIndex = indexPath.row
        cell.titleLabel.text = Utils.getFilmTitle(dataDictionary, row: indexPath.row)
        cell.descriptionLabel.text = Utils.getFilmDescription(dataDictionary, row: indexPath.row)
        cell.thumbnailImage.setImageWithURL(NSURL(string: Utils.getFilmImageUrl(dataDictionary, row: indexPath.row, qualityMode: .Medium))!, placeholderImage: UIImage(named: "defaultCardImage"))
        
//        cell.layer.cornerRadius = 8
        
        return cell
        
    }
    
    // MARK: Collection delegate
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        //print("selected item \(indexPath.row):\(indexPath.section)")
        return true
    }
    
    // MARK: Networking
    
    func fetchPosts(successCallback: (NSDictionary) -> Void, errorCallback: ((NSError?) -> Void)?) {
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
        SwiftLoader.hide()
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
    
}

