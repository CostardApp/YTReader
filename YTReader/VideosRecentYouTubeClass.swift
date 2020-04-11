//
//  LoadVideosFromPlaylistsClass.swift
//  CostardApp
//
//  Created by Brian Costard on 03/06/2018.
//  Copyright © 2018 Brian Costard. All rights reserved.
//

import UIKit

public protocol YTVideosRecentDelegate {
    func loadVideosRecentFinish()
    func loadVideosRecentError()
}

public let YTVideosRecent: VideosRecentYouTubeClass = VideosRecentYouTubeClass()

public class VideosRecentYouTubeClass: NSObject {
    
    private var dataArray = [ValueArray]()
    public var delegate: YTVideosRecentDelegate?

    // ******************** Load videos from playlist ******************** \\
    public func load(YouTubeApiKey: String, PlaylistId: String, MaxResults: Int) {
            dataArray.removeAll()
            var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(MaxResults)&playlistId=\(PlaylistId)&key=\(YouTubeApiKey)"
            
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
            let targetURL = URL(string: urlString)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: targetURL!) {
                data, response, error in
                
                if error != nil {
                    DispatchQueue.main.async(execute: { () -> Void in
                    print(error!.localizedDescription)
                        if self.delegate != nil {
                    self.delegate?.loadVideosRecentError()
                        }
                    return
                    })
                } else {
                    do {
                        typealias JSONObject = [String:AnyObject]
                        
                        let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                        let items  = json["items"] as! Array<JSONObject>
                        
                        for i in 0 ..< items.count {
                            let snippetDictionary = items[i]["snippet"] as! JSONObject
                            //var youVideosFromPlaylistDict = JSONObject()
                            let dict = ValueArray()
                            
                            dict.title_ = snippetDictionary["title"] as! String
                            dict.id_ = snippetDictionary["resourceId"]?["videoId"] as! String
                            dict.publishedAt_ = snippetDictionary["publishedAt"] as! String
                            
                            if ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] != nil {
                                dict.thumbnail_ = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] as! String
                            } else if ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] != nil {
                                dict.thumbnail_ = ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] as! String
                            }  else if ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] != nil {
                                dict.thumbnail_ = ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] as! String
                            }
                            
                            self.dataArray.append(dict)
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            print("Load videos finish!")
                            if self.delegate != nil {
                            self.delegate?.loadVideosRecentFinish()
                            }
                        })
                        
                    } catch {
                        DispatchQueue.main.async(execute: { () -> Void in
                        print("json error: \(error)")
                        if self.delegate != nil {
                        self.delegate?.loadVideosRecentError()
                        }
                        })
                    }
                }
            }
            task.resume()
    }
    
    public func numberOfRowsInSection() -> Int {
        return dataArray.count
    }

    public func title(Index: Int) -> String {
        return dataArray[Index].title_
    }

    public func id(Index: Int) -> String {
        return dataArray[Index].id_
    }

    public func publisheAt(Index: Int) -> String {
        return dataArray[Index].publishedAt_
    }

    public func thumbnail(Index: Int) -> String {
        return dataArray[Index].thumbnail_
    }
}
