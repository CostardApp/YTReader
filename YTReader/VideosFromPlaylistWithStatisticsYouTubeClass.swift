//
//  LoadVideosFromPlaylistWithStatistics.swift
//  CostardApp
//
//  Created by Brian Costard on 05/06/2018.
//  Copyright © 2018 Brian Costard. All rights reserved.
//

import UIKit

public protocol YTVideosFromPlaylistWithStatisticsDelegate {
    func loadVideosFromPlaylistWithStatisticsFinish()
    func loadVideosFromPlaylistWithStatisticsError()
}

public let YTVideosFromPlaylistWithStatistics: VideosFromPlaylistWithStatisticsYouTubeClass = VideosFromPlaylistWithStatisticsYouTubeClass()

public class VideosFromPlaylistWithStatisticsYouTubeClass: NSObject {
    
    public var delegate: YTVideosFromPlaylistWithStatisticsDelegate?
    private var dataArray = [[String: AnyObject]]()
    private var arrayVideoId = [String]()
    private var loadingVideosFromPlaylistWithStatisticsYouTube: Bool = false
    
    // ******************** Load videos from playlist ******************** \\
    public func load(YouTubeApiKey: String, PlaylistId: String, MaxResults: Int) {
        
        if loadingVideosFromPlaylistWithStatisticsYouTube == false {
            loadingVideosFromPlaylistWithStatisticsYouTube = true
            dataArray.removeAll()
            var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(MaxResults)&playlistId=\(PlaylistId)&key=\(YouTubeApiKey)"
            
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
            let targetURL = URL(string: urlString)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: targetURL!) {
                data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.loadingVideosFromPlaylistWithStatisticsYouTube = false
                    self.delegate?.loadVideosFromPlaylistWithStatisticsError()
                    return
                } else {
                    do {
                        typealias JSONObject = [String:AnyObject]
                        
                        let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                        let items  = json["items"] as! Array<JSONObject>
                        
                        for i in 0 ..< items.count {
                            
                            let snippetDictionary = items[i]["snippet"] as! JSONObject
                            //var youVideosFromPlaylistWithStatisticsDict = JSONObject()
                            self.arrayVideoId.append((snippetDictionary["resourceId"]?["videoId"]) as! String)
                            //youVideosFromPlaylistWithStatisticsDict["videoId"] = snippetDictionary["resourceId"]?["videoId"] as AnyObject
                            //self.dataVideosFromPlaylistWithStatisticsYouTubeArray.append(youVideosFromPlaylistWithStatisticsDict)
                            //print(self.dataVideosFromPlaylistWithStatisticsYouTubeArray)
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.loadStatisticsVideo(YouTubeApiKey: YouTubeApiKey)
                        })
                        
                    } catch {
                        print("json error: \(error)")
                        self.loadingVideosFromPlaylistWithStatisticsYouTube = false
                        self.delegate?.loadVideosFromPlaylistWithStatisticsError()
                    }
                }
            }
            task.resume()
        }
    }
    
    func loadStatisticsVideo(YouTubeApiKey: String) {
        //let videoIds = arrayVideoId.joined(separator: ",")
        
        for item in 0 ..< arrayVideoId.count {

        var urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=\(arrayVideoId[item])&key=\(YouTubeApiKey)"
        
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        let targetURL = URL(string: urlString)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: targetURL!) {
            data, response, error in
            
            if error != nil {
                print(error!.localizedDescription)
                self.loadingVideosFromPlaylistWithStatisticsYouTube = false
                self.delegate?.loadVideosFromPlaylistWithStatisticsError()
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
                        var youVideoFromPlaylistWithStatisticsDict = JSONObject()
                        
                        youVideoFromPlaylistWithStatisticsDict["title"] = snippetDictionary["title"]
                        youVideoFromPlaylistWithStatisticsDict["viewCount"] = statisticsDictionary["viewCount"]
                        youVideoFromPlaylistWithStatisticsDict["publishedAt"] = snippetDictionary["publishedAt"]
                        youVideoFromPlaylistWithStatisticsDict["duration"] = contentDetailsDictionary["duration"]
                        youVideoFromPlaylistWithStatisticsDict["likeCount"] = statisticsDictionary["likeCount"]
                        youVideoFromPlaylistWithStatisticsDict["description"] = snippetDictionary["description"]
                        
                        if ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] != nil {
                            youVideoFromPlaylistWithStatisticsDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"]
                        } else if ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] != nil {
                            youVideoFromPlaylistWithStatisticsDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"]
                        }  else if ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] != nil {
                            youVideoFromPlaylistWithStatisticsDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"]
                        }
                        
                        self.dataArray.append(youVideoFromPlaylistWithStatisticsDict)
                    }
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        print("Load videos from playlist with statistics finish!")
                        self.loadingVideosFromPlaylistWithStatisticsYouTube = false
                        self.delegate?.loadVideosFromPlaylistWithStatisticsFinish()
                    })
                    
                } catch {
                    print("json error: \(error)")
                    self.loadingVideosFromPlaylistWithStatisticsYouTube = false
                    self.delegate?.loadVideosFromPlaylistWithStatisticsError()
                }
            }
        }
        task.resume()
        }
    }
    
    public func numberOfRowsInSection() -> Int {
        return arrayVideoId.count
    }

    public func title(Index: Int) -> String {
        return dataArray[Index]["title"] as! String
    }

    public func viewCount(Index: Int) -> String {
        return dataArray[Index]["viewCount"] as! String
    }

    public func likeCount(Index: Int) -> String {
        return dataArray[Index]["likeCount"] as! String
    }

    public func publishedAt(Index: Int) -> String {
        return dataArray[Index]["publishedAt"] as! String
    }
    public func duration(Index: Int) -> String {
        return dataArray[Index]["duration"] as! String
    }

    public func description(Index: Int) -> String {
        return dataArray[Index]["description"] as! String
    }

    public func thumbnail(Index: Int) -> String {
        return dataArray[Index]["thumbnails"] as! String
    }
}
