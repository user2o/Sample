//
//  News.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import Foundation
import SwiftyXML

struct News {
    
    // MARK: - Properties
    
    let guid        : String
    let title       : String   // title
    let link        : String   // link
    let published   : Date     // pubDate
    let description : String   // description
    let imageURL    : URL?     // enclosure->url
    
    // MARK: - Computed Properties
    
    var publishedFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy 'at' HH:mm"
        formatter.timeZone = Calendar.current.timeZone
        return formatter.string(from: published)
    }
    
    var read: Bool {
        UserDefaults.standard.double(forKey: guid) != 0
    }
    
    // MARK: - Lifecycle
    
    /// Failable constructor to create a News object from XML content.
    /// Required properties:
    /// `title, link, description, pubDate`
    ///
    /// Optional properties:
    /// `enclosure url` (the header image) and `guid` (using UUID as fallback)
    /// - Parameter xml: the xml subnode to parse
    init?(xml: XML) {
        
        // Required Properties
        guard var title = xml.title.string else { return nil }
        guard let link = xml.link.string else { return nil }
        guard let descriptionXML = xml.xmlChildren.first(where: { $0.xmlName == "description" }) else { return nil }
        guard var description = descriptionXML.string else { return nil }
        guard let pubDate = xml.pubDate.string else { return nil }
        
        title = title
            .removeHTMLTags()
            .replacingOccurrences(of: " &amp; ", with: " & ")
        
        description = description
            .removeHTMLTags()
            .replacingOccurrences(of: " &amp; ", with: " & ")
        
        self.guid           = xml.guid.string ?? UUID().uuidString
        self.title          = title
        self.link           = link
        self.description    = description
        self.published      = News.dateUTC(from: pubDate)
        
        // Optional Properties
        if let urlString = xml.enclosure.xml?.xmlAttributes["url"] {
            self.imageURL = URL(string: urlString)
        }
        else {
            self.imageURL = nil
        }
    }
    
    // MARK: - Helper
    
    /// Sets or removes the read state for this article.
    /// - Parameter value: true to mark as read, false to mark as unread
    func setRead(_ value: Bool) {
        let timestamp = value ? Date().timeIntervalSince1970 : 0
        UserDefaults.standard.setValue(timestamp, forKey: guid)
    }
    
    /// Takes a date string and turns it into a Date obejct.
    /// Intended for use with news pubDate as the date format is
    /// - Parameter source: string with a potential date to be extracted
    /// - Returns: the extracted date or the current date, e.g. when the format doesn't fit
    static func dateUTC(from source: String) -> Date {
        // Example source: "Thu, 04 Mar 2021 11:53:02 PDT"
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: source) ?? Date()
    }
}
