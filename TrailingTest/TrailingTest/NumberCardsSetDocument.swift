//
//  Document.swift
//  TrailingTest
//
//  Created by 唐泽宇 on 2019/3/28.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import UIKit

class NumberCardsSetDocument: UIDocument {
    
    var numberCardsSet: NumberCardsSet?
    var thumbnail: UIImage?
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return numberCardsSet?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data{
            numberCardsSet = NumberCardsSet(json: json)
        }else {
            print("Error trying to load EmojiArtDocument. Content is not JSON data")
        }
    }
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            // Add our ustom thumbnail image
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
}
