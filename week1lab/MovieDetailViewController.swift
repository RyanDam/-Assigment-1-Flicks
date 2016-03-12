//
//  MovieDetailViewController.swift
//  week1lab
//
//  Created by Dam Vu Duy on 3/9/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var moviePopuler: UILabel!
    
    var data: FillterItem? = FillterItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollview.contentSize = CGSize(width: scrollview.frame.size.width, height:
            infoView.frame.origin.y + infoView.frame.size.height - 100)
        
        // Do any additional setup after loading the view, typically from a nib.
        backdropImage.setImageWithURL(NSURL(string: (data?.imageUrl)!)!)
        movieTitle.text = (data?.title)!
        movieRating.text = "Rating: \((data?.rating)!)"
        moviePopuler.text = "Popular: \((data?.populer)!)"
        
        movieDescription.text = "Description:\n\n" + (data?.description)!
        movieDescription.sizeToFit()
        
        scrollview.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        movieDescription.sizeToFit()
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
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        backdropImage.frame.origin.y = -0.15 * offset
    }
}
