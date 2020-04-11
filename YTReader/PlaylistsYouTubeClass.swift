//
//  LoadPlaylistsClass.swift
//  CostardApp
//
//  Created by Brian Costard on 03/06/2018.
//  Copyright © 2018 Brian Costard. All rights reserved.
//

import UIKit

public protocol YTPlaylistsDelegate {
    func loadPlaylistsFinish()
    func loadPlaylistsError()
}

public let YTPlaylists: PlaylistsYouTubeClass = PlaylistsYouTubeClass()

public class PlaylistsYouTubeClass: NSObject {
    
    public var delegate: YTPlaylistsDelegate?
    private var dataArray = [[String: AnyObject]]()
    private var loadingPlaylistsYouTube: Bool = false

    // ******************** Load playlist ******************** \\
    public func load(YouTubeApiKey: String, ChannelId: String, MaxResults: Int) {
    
        if loadingPlaylistsYouTube == false {
            loadingPlaylistsYouTube = true
            dataArray.removeAll()
            let myGroup = DispatchGroup()
            let queue = DispatchQueue(label: "queueYTPlaylists", qos: DispatchQoS.userInitiated)
            var urlString = "https://www.googleapis.com/youtube/v3/playlists?part=snippet,contentDetails&maxResults=\(MaxResults)&channelId=\(ChannelId)&key=\(YouTubeApiKey)"
        
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
            let targetURL = URL(string: urlString)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
        queue.sync {
            let task = session.dataTask(with: targetURL!) {
                data, response, error in
            
                if error != nil {
                    DispatchQueue.main.async(execute: { () -> Void in
                    print(error!.localizedDescription)
                    self.loadingPlaylistsYouTube = false
                    myGroup.leave()
                    self.delegate?.loadPlaylistsError()
                    return
                    })
                } else {
                    do {
                        typealias JSONObject = [String:AnyObject]
                        
                        let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                        let items  = json["items"] as! Array<JSONObject>
                    
                        for i in 0 ..< items.count {
                            myGroup.enter()
                            let snippetDictionary = items[i]["snippet"] as! JSONObject
                            let contentDetailsDictionary = items[i]["contentDetails"] as! JSONObject
                            var youPlaylistsDict = JSONObject()
                            
                            youPlaylistsDict["title"] = snippetDictionary["title"]
                            youPlaylistsDict["itemCount"] = contentDetailsDictionary["itemCount"]
                            youPlaylistsDict["id"] = items[i]["id"]
                            
                            if ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] != nil {
                                youPlaylistsDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"]
                            } else if ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"] != nil {
                                youPlaylistsDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["medium"] as! JSONObject)["url"]
                            }  else if ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] != nil {
                                youPlaylistsDict["thumbnails"] = ((snippetDictionary["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"]
                            }
                        
                            self.dataArray.append(youPlaylistsDict)
                            myGroup.leave()
                        }
                    
                        myGroup.notify(queue: DispatchQueue.main) {
                            print("Load playlists finish!")
                            self.loadingPlaylistsYouTube = false
                            self.delegate?.loadPlaylistsFinish()
                        }
                    
                    } catch {
                        DispatchQueue.main.async(execute: { () -> Void in
                        print("json error: \(error)")
                        self.loadingPlaylistsYouTube = false
                        myGroup.leave()
                        self.delegate?.loadPlaylistsError()
                        })
                    }
                }
            }
            task.resume()
            }
        }
    }

    public func numberOfRowsInSection() -> Int {
        return dataArray.count
    }

    public func title(Index: Int) -> String {
        return dataArray[Index]["title"] as! String
    }

    public func id(Index: Int) -> String {
        return dataArray[Index]["id"] as! String
    }

    public func itemCount(Index: Int) -> Int {
        return dataArray[Index]["itemCount"] as! Int
    }

    public func thumbnail(Index: Int) -> String {
        return dataArray[Index]["thumbnails"] as! String
    }
}

