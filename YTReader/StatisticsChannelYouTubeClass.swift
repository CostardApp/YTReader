//
//  LoadStatisticsChannelClass.swift
//  CostardApp
//
//  Created by Brian Costard on 03/06/2018.
//  Copyright © 2018 Brian Costard. All rights reserved.
//

import UIKit

public protocol YTChannelStatisticsDelegate {
    func loadStatisticsChannelFinish()
    func loadStatisticsChannelError()
}

public let YTChannelStatistics: StatisticsChannelYouTubeClass = StatisticsChannelYouTubeClass()

public class StatisticsChannelYouTubeClass: NSObject {
    
    public var delegate: YTChannelStatisticsDelegate?
    private var dataArray = [[String: AnyObject]]()
    private var loadingStatisticsChannelYouTube: Bool = false

    // ******************** Load statistics channel ******************** \\
    public func load(YouTubeApiKey: String, ChannelId: String) {
        
        if loadingStatisticsChannelYouTube == false {
            loadingStatisticsChannelYouTube = true
            dataArray.removeAll()
            var urlString = "https://www.googleapis.com/youtube/v3/channels?part=snippet,brandingSettings,statistics&id=\(ChannelId)&key=\(YouTubeApiKey)"
            
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
            let targetURL = URL(string: urlString)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: targetURL!) {
                data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.loadingStatisticsChannelYouTube = false
                    self.delegate?.loadStatisticsChannelError()
                    return
                } else {
                    do {
                        typealias JSONObject = [String:AnyObject]
                        
                        let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                        let items  = json["items"] as! Array<JSONObject>
                        
                        for i in 0 ..< items.count {
                            
                            let statisticsDictionary = items[i]["statistics"] as! JSONObject
                            let snippetDictionary = items[i]["snippet"] as! JSONObject
                            var youStatisticsChannelDict = JSONObject()
                            
                            youStatisticsChannelDict["title"] = snippetDictionary["title"]
                            youStatisticsChannelDict["viewCount"] = statisticsDictionary["viewCount"]
                            youStatisticsChannelDict["videoCount"] = statisticsDictionary["videoCount"]
                            youStatisticsChannelDict["subscriberCount"] = statisticsDictionary["subscriberCount"]
                            
                            if ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] != nil {
                                youStatisticsChannelDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"]
                            } else if ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] != nil {
                                youStatisticsChannelDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"]
                            }  else if ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] != nil {
                                youStatisticsChannelDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"]
                            }
                            
                            self.dataArray.append(youStatisticsChannelDict)
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            print("Load statistics channel finish!")
                            self.loadingStatisticsChannelYouTube = false
                            self.delegate?.loadStatisticsChannelFinish()
                        })
                        
                    } catch {
                        print("json error: \(error)")
                        self.loadingStatisticsChannelYouTube = false
                        self.delegate?.loadStatisticsChannelError()
                    }
                }
            }
            task.resume()
        }
    }
    
    public func title() -> String {
        return dataArray[0]["title"] as! String
    }
    
    public func viewCount() -> String {
        return dataArray[0]["viewCount"] as! String
    }
    
    public func videoCount() -> String {
        return dataArray[0]["videoCount"] as! String
    }
    
    public func subscriberCount() -> String {
        return dataArray[0]["subscriberCount"] as! String
    }
    
    public func thumbnail() -> String {
        return dataArray[0]["thumbnails"] as! String
    }
}
