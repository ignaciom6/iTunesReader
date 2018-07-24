//
//  MediaConnectionServiceManager.swift
//  iTunesReader
//
//  Created by Ignacio on 20/7/18.
//  Copyright © 2018 Ignacio. All rights reserved.
//

import Foundation

protocol MediaNotifierDelegate {
    func notifyRequestSuccessWithDictionary(mediaDictionary: Dictionary<String, AnyObject>)
    func notifyRequestErrorWithError(error: Error)
}

class MediaConnectionServiceManager
{
    var delegate : MediaNotifierDelegate?
    
    static let sharedInstance = MediaConnectionServiceManager()
    private init () {}
    
    let url = "https://itunes.apple.com/search"
    
    func requestServiceForArtist(artist: String, media: String) {
        let manager = AFHTTPSessionManager()
        let parameters = ["term":artist, "media":media]
        manager.get(url,
                    parameters: parameters,
                    progress: nil,
                    success: {
                        (operation, responseObject) -> Void in
                        if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                            let resultCount : NSNumber = jsonResult["resultCount"] as! NSNumber
                            print(resultCount)
                            self.delegate?.notifyRequestSuccessWithDictionary(mediaDictionary: jsonResult)
                        }
                        
        },
                    failure: {
                        (operation, error) -> Void in
                        self.delegate?.notifyRequestErrorWithError(error: error)
        })
    }
    
}
