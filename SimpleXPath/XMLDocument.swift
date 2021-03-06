//
//  XMLDocument.swift
//  SimpleXPath
//
//  Created by CHEN Xian’an on 2/19/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

import libxml2

public enum XMLDocumentType: Int {
  case XML
  case HTML
}

public final class XMLDocument {
  
  public let data: NSData
  
  public let documentType: XMLDocumentType
  
  public let encoding: NSStringEncoding
  
  public init?(data d: NSData, documentType type: XMLDocumentType = .XML, encoding enc: NSStringEncoding = NSUTF8StringEncoding) {
    data = d
    documentType = type
    encoding = enc
    let buffer = unsafeBitCast(data.bytes, UnsafePointer<Int8>.self)
    let size = Int32(data.length)
    let cfenc = CFStringConvertNSStringEncodingToEncoding(encoding)
    let iana = CFStringConvertEncodingToIANACharSetName(cfenc)
    let ianaChar = (iana as NSString).UTF8String
    switch type {
    case .XML:
      _xmlDoc = xmlReadMemory(buffer, size, nil, ianaChar, Int32(XML_PARSE_NOBLANKS.rawValue))
    case .HTML:
      _xmlDoc = htmlReadMemory(buffer, size, nil, ianaChar, Int32(HTML_PARSE_RECOVER.rawValue | HTML_PARSE_NOBLANKS.rawValue | HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue))
    }
    
    _root = xmlDocGetRootElement(_xmlDoc)
    if _xmlDoc == nil || _root == nil { return nil }
  }
  
  public convenience init?(string s: String, documentType type: XMLDocumentType = .XML, encoding enc: NSStringEncoding = NSUTF8StringEncoding) {
    guard let data = s.dataUsingEncoding(enc) else { return nil }
    self.init(data: data, documentType: type, encoding: enc)
  }
  
  deinit {
    xmlFreeDoc(_xmlDoc)
  }
  
  internal let _xmlDoc: xmlDocPtr
  
  internal let _root: xmlNodePtr
  
}

public extension XMLDocument {
  
  func rootElement() -> XMLElement {
    return XMLElement(_root, self)
  }
  
  func registerDefaultNamespace(namespaceHref: String, usingPrefix prefix: String) {
    xmlNewNs(xmlDocGetRootElement(_xmlDoc), namespaceHref.xmlCharPointer, prefix.xmlCharPointer)
  }
  
}

extension XMLDocument: XPathLocating {
  
  public func selectElements(withXPath: String) -> [XMLElement] {
    return rootElement().selectElements(withXPath)
  }
  
  public func selectFirstElement(withXPath: String) -> XMLElement? {
    return rootElement().selectFirstElement(withXPath)
  }
  
}

extension XMLDocument: XPathFunctionEvaluating {
  
  public func evaluate(XPathFunction: String) -> XPathFunctionResult? {
    return rootElement().evaluate(XPathFunction)
  }
  
}
