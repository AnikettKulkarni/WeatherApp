//
//  WeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import UIKit

class WeatherAppCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var yearLable: UILabel!
    @IBOutlet weak var monthLable: UILabel!
    @IBOutlet weak var maximumTemperatureLable: UILabel!
    @IBOutlet weak var minimumTemperatureLable: UILabel!
    @IBOutlet weak var rainfallLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
