//
//  LoadSearchVideosClass.swift
//  CostardApp
//
//  Created by Brian Costard on 03/06/2018.
//  Copyright © 2018 Brian Costard. All rights reserved.
//

import UIKit

public protocol YTSearchVideosDelegate {
    func loadSearchVideosFinish()
    func loadSearchVideosError()
}

public let YTSearchVideos: SearchVideosYouTubeClass = SearchVideosYouTubeClass()

public class SearchVideosYouTubeClass: NSObject {
    
    public var delegate: YTSearchVideosDelegate?
    private var dataArray = [[String: AnyObject]]()
    private var loadingSearchVideosYouTube: Bool = false

    // ******************** Load search videos ******************** \\
    public func load(YouTubeApiKey: String, Tags: String, MaxResults: Int) {
        
        if loadingSearchVideosYouTube == false {
            loadingSearchVideosYouTube = true
            dataArray.removeAll()
            var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=viewCount&q=\(Tags)&type=video&maxResults=\(MaxResults)&key=\(YouTubeApiKey)"
            
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
            let targetURL = URL(string: urlString)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: targetURL!) {
                data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.loadingSearchVideosYouTube = false
                    self.delegate?.loadSearchVideosError()
                    return
                } else {
                    do {
                        typealias JSONObject = [String:AnyObject]
                        
                        let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                        let items  = json["items"] as! Array<JSONObject>
                        
                        for i in 0 ..< items.count {
                            
                            let snippetDictionary = items[i]["snippet"] as! JSONObject
                            let idDictionary = items[i]["id"] as! JSONObject
                            var youSearchVideosDict = JSONObject()
                            
                            youSearchVideosDict["title"] = snippetDictionary["title"]
                            youSearchVideosDict["channelTitle"] = snippetDictionary["channelTitle"]
                            youSearchVideosDict["videoId"] = idDictionary["videoId"]
                            
                            if ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] != nil {
                                youSearchVideosDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"]
                            } else if ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] != nil {
                                youSearchVideosDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"]
                            }  else if ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] != nil {
                                youSearchVideosDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"]
                            }
                            
                            self.dataArray.append(youSearchVideosDict)
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            print("Load search videos finish!")
                            self.loadingSearchVideosYouTube = false
                            self.delegate?.loadSearchVideosFinish()
                        })
                        
                    } catch {
                        print("json error: \(error)")
                        self.loadingSearchVideosYouTube = false
                        self.delegate?.loadSearchVideosError()
                    }
                }
            }
            task.resume()
        }
    }
    
    public func numberOfRowsInSection() -> Int {
        return dataArray.count
    }
    
    public func titleVideo(Index: Int) -> String {
        return dataArray[Index]["title"] as! String
    }
    
    public func titleChannel(Index: Int) -> String {
        return dataArray[Index]["channelTitle"] as! String
    }
    
    public func idVideo(Index: Int) -> String {
        return dataArray[Index]["videoId"] as! String
    }
    
    public func thumbnailVideo(Index: Int) -> String {
        return dataArray[Index]["thumbnails"] as! String
    }
}
