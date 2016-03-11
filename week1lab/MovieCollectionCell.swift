//
//  MovieCollectionCell.swift
//  week1lab
//
//  Created by Dam Vu Duy on 3/8/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    var rowIndex: Int = -1
}
