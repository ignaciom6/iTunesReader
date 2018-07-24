//
//  MediaConnectionManager.swift
//  iTunesReader
//
//  Created by Ignacio on 20/7/18.
//  Copyright © 2018 Ignacio. All rights reserved.
//

import Foundation

class MediaConnectionManager
{
    //Singleton
    static let sharedInstance = MediaConnectionManager()
    private init () {}
    
    let connectionServiceManager : MediaConnectionServiceManager = MediaConnectionServiceManager.sharedInstance
    let kMusicMediaString = "Music"
    let kTvShowMediaString = "Tv Show"
    let kMovieMediaString = "Movie"
    var mediaSelected: String = ""
    
    func requestMediaForArtist(artist: String, media: String) {
        connectionServiceManager.delegate = self
        
        if media == kMusicMediaString {
            mediaSelected = "music"
        } else if media == kTvShowMediaString {
            mediaSelected = "tvShow"
        } else if media == kMovieMediaString {
            mediaSelected = "movie"
        }
        
        connectionServiceManager.requestServiceForArtist(artist: artist, media: mediaSelected)
        
    }
}

extension MediaConnectionManager : MediaNotifierDelegate
{
    func notifyRequestSuccessWithDictionary(mediaDictionary: Dictionary<String, AnyObject>) {
        let resultsArrary : NSArray = mediaDictionary["results"] as! NSArray
        print(resultsArrary.count, mediaSelected)
        
        NotificationCenter.default.post(name: .searchResult, object: resultsArrary)
    }
    
    func notifyRequestErrorWithError(error: Error) {
        print(error)
    }
    
}
