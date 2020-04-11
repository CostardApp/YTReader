//
//  LoadStatisticsVideoClass.swift
//  CostardApp
//
//  Created by Brian Costard on 04/06/2018.
//  Copyright © 2018 Brian Costard. All rights reserved.
//

import UIKit

public protocol YTVideoStatisticsDelegate {
    func loadStatisticsVideoFinish()
    func loadStatisticsVideoError()
}

public let YTVideoStatistics: StatisticsVideoYouTubeClass = StatisticsVideoYouTubeClass()

public class StatisticsVideoYouTubeClass: NSObject {
    
    public var delegate: YTVideoStatisticsDelegate?
    private var dataArray = [[String: AnyObject]]()
    private var loadingStatisticsVideoYouTube: Bool = false
    
    // ******************** Load statistics channel ******************** \\
    public func load(YouTubeApiKey: String, VideoId: String) {
        
        if loadingStatisticsVideoYouTube == false {
            loadingStatisticsVideoYouTube = true
            dataArray.removeAll()
            var urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=\(VideoId)&key=\(YouTubeApiKey)"
            
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
            let targetURL = URL(string: urlString)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: targetURL!) {
                data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.loadingStatisticsVideoYouTube = false
                    self.delegate?.loadStatisticsVideoError()
                    return
                } else {
                    do {
                        typealias JSONObject = [String:AnyObject]
                        
                        let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                        let items  = json["items"] as! Array<JSONObject>
                        
                        for i in 0 ..< items.count {
                            
                            let statisticsDictionary = items[i]["statistics"] as! JSONObject
                            let snippetDictionary = items[i]["snippet"] as! JSONObject
                            let contentDetailsDictionary = items[i]["contentDetails"] as! JSONObject
                            var youStatisticsVideoDict = JSONObject()
                            
                            youStatisticsVideoDict["title"] = snippetDictionary["title"]
                            youStatisticsVideoDict["viewCount"] = statisticsDictionary["viewCount"]
                            youStatisticsVideoDict["publishedAt"] = snippetDictionary["publishedAt"]
                            youStatisticsVideoDict["duration"] = contentDetailsDictionary["duration"]
                            youStatisticsVideoDict["likeCount"] = statisticsDictionary["likeCount"]
                            youStatisticsVideoDict["description"] = snippetDictionary["description"]
                            
                            if ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] != nil {
                                youStatisticsVideoDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"]
                            } else if ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] != nil {
                                youStatisticsVideoDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"]
                            }  else if ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] != nil {
                                youStatisticsVideoDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"]
                            }
                            
                            self.dataArray.append(youStatisticsVideoDict)
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            print("Load statistics channel finish!")
                            self.loadingStatisticsVideoYouTube = false
                            self.delegate?.loadStatisticsVideoFinish()
                        })
                        
                    } catch {
                        print("json error: \(error)")
                        self.loadingStatisticsVideoYouTube = false
                        self.delegate?.loadStatisticsVideoError()
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
    
    public func likeCount() -> String {
        return dataArray[0]["likeCount"] as! String
    }
    
    public func publishedAt() -> String {
        return dataArray[0]["publishedAt"] as! String
    }
    public func duration() -> String {
        return dataArray[0]["duration"] as! String
    }
    
    public func description() -> String {
        return dataArray[0]["description"] as! String
    }
    
    public func thumbnail() -> String {
        return dataArray[0]["thumbnails"] as! String
    }
}

