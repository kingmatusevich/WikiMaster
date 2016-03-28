//
//  WikiMasterTests.swift
//  WikiMasterTests
//
//  Created by Javier Matusevich on 27/3/16.
//  Copyright © 2016 Javier Matusevich. All rights reserved.
//

import XCTest
@testable import WikiMaster

class WikiMasterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRandomArticleRequest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let queries = WikiQueries()
        let asyncExpectation = expectationWithDescription("gettingRandomArticle")
        queries.getRandomArticles(count:10)
            {
                items in
                guard let articles: Array<WikiQueries.Article> = items else
                {
                    
                    XCTFail("no articles")
                    asyncExpectation.fulfill()
                    return
                }
                XCTAssert(articles.count > 0)
                articles.forEach(){
                    article in
                    print("\(article.pageID): \(article.title) with ns: \(article.ns) and redirect: \(article.redirect)")
                }
                guard let first = articles.first else
                {
                    asyncExpectation.fulfill()
                    return
                }
                queries.getBacklinks(title: first.title){
                    items in
                    guard let articles: Array<WikiQueries.Article> = items else
                    {
                        XCTFail("no articles format")
                        asyncExpectation.fulfill()
                        return
                    }
                    XCTAssert(articles.count > 0)
                    articles.forEach(){
                        article in
                        print("\(article.pageID): \(article.title) with ns: \(article.ns) and redirect: \(article.redirect)")
                    }
                    asyncExpectation.fulfill()
                    
                }
        }
        self.waitForExpectationsWithTimeout(50) { error in
            if (error != nil) {XCTFail("timeout")}
        }
    }
    
}
