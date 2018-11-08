//
//  PinPost.swift
//  Post-Lit
//
//  Created by Sam on 11/1/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//

import AVFoundation

class PinPost {
    
    var duration: Timer?
    var videoAsString: String
    var title: String
    var rating: Int
    var reports: Int
    
    init(duration: Timer?, videoAsString: String, title: String, rating: Int, reports: Int) {
        self.videoAsString = videoAsString
        self.duration = duration
        self.title = title
        self.rating = rating
        self.reports = reports
    }
}
