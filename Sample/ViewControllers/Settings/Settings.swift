//
//  Settings.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

struct Settings: Codable {
    
    private enum Key: String { case settings }
    
    static var shared: Settings {
        Settings.open() ?? Settings()
    }
    
    let rssGrayscaleReadArticles    : Bool
    let rssFeedURL                  : URL
    let apiKey                      : String
    
    init(grayscale: Bool? = nil,
         feedURL: URL? = nil,
         apiKey: String? = nil)
    {
        // Open stored settings as
        let stored = Settings.open()
        
        self.rssGrayscaleReadArticles = grayscale // use passed in value
            ?? stored?.rssGrayscaleReadArticles // fall back to stored value
            ?? true // fall back to default value
        
        self.rssFeedURL = feedURL
            ?? stored?.rssFeedURL
            ?? URL(string: "https://movieweb.com/rss/all-news/")!
        
        self.apiKey = apiKey
            ?? stored?.apiKey
            ?? ""
        
    }
    
    func store() -> Bool {
        
        let encoder = JSONEncoder()
        guard let result = try? encoder.encode(self) else {
            print("⚠️ Error! Unable to store settings")
            return false
        }
        
        UserDefaults.standard.setValue(result, forKey: Key.settings.rawValue)
        
        return UserDefaults.standard.synchronize()
    }
    
    // MARK: Static Functions
    
    private static func open() -> Settings? {
        
        guard let data = UserDefaults.standard.data(forKey: Key.settings.rawValue) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let stored = try? decoder.decode(Settings.self, from: data) else {
            return nil
        }
        
        return stored
    }
    
}
