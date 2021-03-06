//
//  Utils.swift
//  week1lab
//
//  Created by Dam Vu Duy on 3/9/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import SystemConfiguration

enum PosterQuality {
    case Low
    case Medium
    case Hight
}

class Utils {
    static func getFilmTitle(dataDictionary: NSDictionary?, row: Int) -> String {
        if let dict = dataDictionary {
            return dict["results"]![row]["title"] as! String
        }
        return ""
    }
    
    static func getFilmDescription(dataDictionary: NSDictionary?, row: Int) -> String {
        if let dict = dataDictionary {
            return dict["results"]![row]["overview"] as! String
        }
        return ""
    }
    
    static func getFilmRating(dataDictionary: NSDictionary?, row: Int) -> Double {
        if let dict = dataDictionary {
            return dict["results"]![row]["vote_average"] as! Double
        }
        return 0
    }
    
    static func getFilmPopular(dataDictionary: NSDictionary?, row: Int) -> Double {
        if let dict = dataDictionary {
            return dict["results"]![row]["popularity"] as! Double
        }
        return 0
    }
    
    static let poster_path_low = "https://image.tmdb.org/t/p/w45"
    static let poster_path_hight = "https://image.tmdb.org/t/p/original"
    static let poster_path_medium = "https://image.tmdb.org/t/p/w342"
    
    static func getFilmImageUrl(dataDictionary: NSDictionary?, row: Int, qualityMode: PosterQuality) -> String {
        if let dict = dataDictionary {
            switch (qualityMode) {
            case .Low:
                return poster_path_low + (dict["results"]![row]["poster_path"] as! String) ?? ""
            case .Medium:
                return poster_path_medium + (dict["results"]![row]["poster_path"] as! String) ?? ""
            case .Hight:
                return poster_path_hight + (dict["results"]![row]["poster_path"] as! String) ?? ""
            }
        }
        return ""
    }
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
