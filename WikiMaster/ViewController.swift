//
//  ViewController.swift
//  WikiMaster
//
//  Created by Javier Matusevich on 27/3/16.
//  Copyright © 2016 Javier Matusevich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var firstArticleLabel: UILabel!
    @IBOutlet weak var secondArticleLabel: UILabel!
    @IBOutlet weak var thirdArticleLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    
    var articlePool = Array<WikiQueries.Article>()
    var currentArticle: WikiQueries.Article?
    var currentArticleBackLinks: Array<WikiQueries.Article>?
    
    var queries = WikiQueries()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //getArticles()
    }
    
    func getArticles()
    {
        queries.getRandomArticles(count: 10) {
            articles in
            guard let array = articles else
            {
                return
            }
            self.articlePool.appendContentsOf(array)
            if (self.currentArticle == nil)
            {
                self.startNewQuestion()
            }
        }
    }
    
    func startNewQuestion()
    {
        guard let nextArticle = articlePool.randomItem() else
        {
            getArticles()
            return
        }
        currentArticle = nextArticle
        getCurrentArticleBacklinks()
    }
    
    func getCurrentArticleBacklinks()
    {
        guard let article = currentArticle else
        {
            startNewQuestion()
            return
        }
        queries.getBacklinks(title: article.title, limit: 30){
            articles in
            guard let array = articles else
            {
                return
            }
            guard array.count >= 3 else
            {
                self.currentArticle = nil
                self.startNewQuestion()
                return
            }
            self.currentArticleBackLinks = Array<WikiQueries.Article>()
            for _ in 1...3 {
                guard let anItem = array.randomItem() else
                {
                    self.currentArticle = nil
                    self.currentArticleBackLinks = nil
                    self.startNewQuestion()
                    return
                }
                self.currentArticleBackLinks?.append(anItem)
            }
            
            
            
        }
    }
    
    func updateUI()
    {
        guard let article = currentArticle else {
            startNewQuestion()
            return
        }
        guard let backlinks = currentArticleBackLinks where
        backlinks.count > 3 else
        {
            currentArticle = nil
            currentArticleBackLinks = nil
            startNewQuestion()
            return
        }
        let buttons = [firstButton, secondButton, thirdButton]
        var buttonsSet: Set<UIButton> = [firstButton, secondButton, thirdButton]
        guard let aButton = buttons.randomItem() else
        {
            return
        }
        aButton.setTitle(article.title, forState: .Normal)
        buttonsSet.remove(aButton)
        for someButton in buttonsSet
        {
            guard let anArticle = articlePool.randomItem() else
            {
                currentArticleBackLinks = nil
                currentArticle = nil
                startNewQuestion()
                return
            }
            someButton.setTitle(anArticle.title, forState: .Normal)
        }
        let labels = [firstArticleLabel, secondArticleLabel, thirdArticleLabel]
        for index in 0...2 {
            let aLabel = labels[index]
            let anArticle = backlinks[index]
            aLabel.text = anArticle.title
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension Array {
    func randomItem() -> Element? {
        guard self.count > 0 else
        {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
