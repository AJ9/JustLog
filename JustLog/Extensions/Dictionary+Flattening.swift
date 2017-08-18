//
//  Dictionary+Flattening.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation


extension Dictionary {
    
    func flattened() -> [String : Any] {
        
        var retVal = [String : Any]()
        
        for (k, v) in self {
            switch v {
            case is String:
                retVal.updateValue(v, forKey: k as! String)
            case is Int:
                retVal.updateValue(v, forKey: k as! String)
            case is Double:
                retVal.updateValue(v, forKey: k as! String)
            case is Bool:
                retVal.updateValue(v, forKey: k as! String)
            case is Dictionary:
                let inner = (v as! [String : Any]).flattened()
                retVal = retVal.merged(with: inner)
            case is Array<Any>:
                retVal.updateValue(String(describing: v), forKey: k as! String)
            case is NSError:
                let inner = (v as! NSError)
                retVal = retVal.merged(with: inner.userInfo.flattened())
            default:
                continue
            }
        }
        
        return retVal
    }
}

extension Dictionary where Key == String {
    
    /// Defines how the dictionary will be flattened and the key-value pairs will be merged.
    ///
    /// - override: Overrides the keys and the values.
    /// - encapsulateFlatten: keeps the keys and adds the values to an array.
    enum KeyMergePolicy {
        case override
        case encapsulateFlatten
    }
    
    func merged(with dictionary: Dictionary<String, Any>, policy: KeyMergePolicy = .override) -> Dictionary<String, Any> {
        switch policy {
        case .override:
            return mergeDictionaryByReplacingValues(self, with: dictionary)
        case .encapsulateFlatten:
            return mergeDictionariesByGroupingValues(self, with: dictionary)
        }
    }
    
    private func mergeDictionaryByReplacingValues(_ dictionary: Dictionary<String, Any>, with dictionary2: Dictionary<String, Any>) -> Dictionary<String, Any> {
        var retValue = dictionary
        dictionary2.forEach { (key, value) in
            retValue.updateValue(value, forKey: key)
        }
        return retValue
    }
    
    private func mergeDictionariesByGroupingValues(_ dictionary: Dictionary<String, Any>, with dictionary2: Dictionary<String, Any>) -> Dictionary<String, Any> {
        var retVal: Dictionary<String, Any> = [:]
        dictionary2.forEach { (key, value) in
            if let value1 = dictionary[key] {
                let mergedValue: [Any] = [value1, value]
                retVal.updateValue(mergedValue, forKey: key)
            }
            else {
                retVal.updateValue(value, forKey: key)
            }
        }
        return retVal
    }
}
