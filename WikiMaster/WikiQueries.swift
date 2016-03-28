//
//  WikiQueries.swift
//  WikiMaster
//
//  Created by Javier Matusevich on 27/3/16.
//  Copyright © 2016 Javier Matusevich. All rights reserved.
//

import Foundation

public class WikiQueries: NSObject {
    public enum WikiNamespaces: String {
        case Articles = "0"
    }
    public struct Article {
        let pageID: Int
        let ns: Int
        let title: String
        let redirect: String
    }
    
    public typealias WikiQueryCompletion = (articles: Array<Article>?)-> ()
    //public typealias ArticleResult = (pageid: Int, ns: Int, title: String, redirect: String)
    internal enum WikiAPIRequests {
        case RandomArticles(namespace: WikiNamespaces, count: Int)
        case BackLinks(namespace: WikiNamespaces, title: String, limit: Int)
    }
    
    internal let WikiAPIString = "https://en.wikipedia.org/w/api.php?"
    
    internal enum WikiAPIParameters: String {
        case ActionQuery                    = "action=query"
        case RandomNamespace                = "rnnamespace="
        case RandomList                     = "list=random"
        case RandomLimit                    = "rnlimit="
        case BacklinkRedirect               = "blredirect="
        case BacklinkNoRedirectsValue       = "nonredirects"
        case BacklinkOnlyRedirectsValue     = "redirects"
        case BacklinkAllRedirectsValue      = "all"
        case BacklinkTitle                  = "bltitle="
        case BacklinkNamespace              = "blnamespace="
        case BacklinkLimit                  = "bllimit="
        case BacklinkList                   = "list=backlinks"
        case JSONFormat                     = "format=json"
        
    }
    
    public func getRandomArticles(namespace: WikiNamespaces = .Articles, count: Int = 1,  completionHandler: WikiQueryCompletion)
    {
        guard count <= 20 else
        {
            return
        }
        let request = WikiAPIRequests.RandomArticles(namespace: namespace, count: count)
        guard let requestURL = createAPIURL(request: request) else
        {
            return
        }
        performAPIQuery(requestURL, completionHandler: completionHandler)
    }
    
    public func getBacklinks(namespace: WikiNamespaces = .Articles, title: String, limit: Int = 10, completionHandler: WikiQueryCompletion)
    {
        guard limit <= 500 else
        {
            return
        }
        let request = WikiAPIRequests.BackLinks(namespace: namespace, title: title, limit: limit)
        guard let requestURL = createAPIURL(request: request) else
        {
            return
        }
        performAPIQuery(requestURL, completionHandler: completionHandler)
    }
    
    func performAPIQuery(url: NSURL, completionHandler: WikiQueryCompletion)
    {
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(url){
            (data, response, error) -> Void in
            guard error == nil else
            {
                completionHandler(articles: nil)
                return
            }
            guard let someData = data else
            {
                completionHandler(articles: nil)
                return
            }
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(someData, options: .AllowFragments)
                guard let jsonDictionary = jsonObject["query"] as? NSDictionary else
                {
                    completionHandler(articles: nil)
                    return
                }
                guard let articleArray = jsonDictionary[(jsonDictionary.allKeys.first as! String)] as? [NSDictionary] else
                {
                    completionHandler(articles: Array<Article>())
                    return
                }
                let newResult: Array<Article> = articleArray.map({
                    let dictionary = $0
                    let id = (dictionary["id"] as! NSNumber).integerValue
                    let pageID = id
                    let ns = (dictionary["ns"] as! NSNumber).integerValue
                    let title = dictionary["title"] as! String
                    var redirect: String;
                    if let aRedirect = dictionary["redirect"] as? String
                    {
                        redirect = aRedirect
                    } else
                    {
                        redirect = ""
                    }
                    
                    return Article(pageID: pageID, ns: ns, title: title, redirect: redirect)
                })
                completionHandler(articles: newResult);
            } catch
            {
                completionHandler(articles: nil)
                return
            }
            
        }
        dataTask.resume()

    }
    
    func createAPIURL(request aRequest: WikiAPIRequests) -> NSURL?
    {
        switch aRequest {
        case let .RandomArticles(namespace, count):
            return queryURL(randomNamespace: namespace, count: count)
        case let .BackLinks(namespace, title, limit):
            return queryURL(backlinkNamespace: namespace, title: title, limit: limit)
        }
    }
    
    func queryURL(randomNamespace randomNamespace: WikiNamespaces, count: Int) -> NSURL?
    {
        let string = "\(WikiAPIString)\(WikiAPIParameters.ActionQuery.rawValue)&\(WikiAPIParameters.RandomNamespace.rawValue)\(randomNamespace.rawValue)&\(WikiAPIParameters.RandomList.rawValue)&\(WikiAPIParameters.RandomLimit.rawValue)\(count)&\(WikiAPIParameters.JSONFormat.rawValue)"
        return NSURL(string: string);
    }
    
    func queryURL(backlinkNamespace namespace: WikiNamespaces, title: String, limit: Int) -> NSURL?
    {
        
        let escapedTitle = title.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let string = "\(WikiAPIString)\(WikiAPIParameters.ActionQuery.rawValue)&\(WikiAPIParameters.BacklinkNamespace.rawValue)\(namespace)&\(WikiAPIParameters.BacklinkList.rawValue)&\(WikiAPIParameters.BacklinkTitle.rawValue)\(escapedTitle)&\(WikiAPIParameters.BacklinkList.rawValue)\(limit)&\(WikiAPIParameters.BacklinkRedirect.rawValue)\(WikiAPIParameters.BacklinkNoRedirectsValue.rawValue)&\(WikiAPIParameters.JSONFormat.rawValue)"
        return NSURL(string: string)
    }
}
