//
//  XMLParser.swift
//  rndSoap
//
//  Created by Marielle Miranda on 8/10/16.
//  Copyright © 2016 Bluesky Outsourcing Ltd. All rights reserved.
//

import UIKit

protocol XMLParserDelegate {
    func xmlParserDidFinish(parsedDictionary: NSDictionary) -> Void
}

class XMLParser: NSObject, NSXMLParserDelegate {
    
    //MARK: - Properties
    
    //MARK: Public
    
    var data: NSData?
    var request: WebServiceFor?
    var delegate: XMLParserDelegate?
    
    //MARK: Private
    
    private var _xmlParser: NSXMLParser?
    private var xmlParser: NSXMLParser {
        get {
            if self._xmlParser == nil {
                self._xmlParser = NSXMLParser(data: self.data!)
                self._xmlParser?.delegate = self
            }
            
            return self._xmlParser!
        }
    }
    
    private var parsedDictionary = NSMutableDictionary()
    private var key = ""
    private var object: NSMutableString?
    
    private var array: NSMutableArray?
    private var arrayDictionary: NSMutableDictionary?
    
    //MARK: - Methods
    
    func parse() -> Void {
        self.xmlParser.parse()
    }
    
    //MARK: - NSXMLParser Delegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.key = elementName
        self.object = NSMutableString()
        
        if elementName == "LINKEDCARDNUMBER" || elementName == "LAST5TRANSACTION" {
            self.array = NSMutableArray()
        } else if elementName == "LINK" || elementName == "TRANSACTION" {
            self.arrayDictionary = NSMutableDictionary()
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.object == nil {
            self.object = NSMutableString()
        }
        
//        if self.key != "" {
//            parsedDictionary.setObject(self.object!, forKey: self.key)
//        }
        
        if elementName == "LINKEDCARDNUMBER" {
            parsedDictionary.setObject(self.array!, forKey: "LinkedCards")
            self.array = nil
        } else if elementName == "LAST5TRANSACTION" {
            parsedDictionary.setObject(self.array!, forKey: "Transactions")
            self.array = nil
        } else if elementName == "LINK" || elementName == "TRANSACTION" {
            self.array!.addObject(self.arrayDictionary!)
            self.arrayDictionary = nil
        }
        
        if self.array != nil && self.arrayDictionary != nil {
            self.arrayDictionary!.setObject(self.object!, forKey: self.key)
        } else {
            parsedDictionary.setObject(self.object!, forKey: self.key)
        }

        
        self.object = nil
        self.key = ""
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if string != "" {
            self.object!.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("Parser error >>> \(parseError)")
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
             
        self.parsedDictionary.setObject(self.request!.rawValue, forKey: "request")
        self.delegate?.xmlParserDidFinish(parsedDictionary)
        
        self._xmlParser = nil
    }
}
