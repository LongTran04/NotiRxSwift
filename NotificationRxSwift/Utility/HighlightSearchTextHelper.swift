//
//  HighlightSearchTextHelper.swift
//  NotificationRxSwift
//
//  Created by Long Tran on 21/06/2023.
//

import Foundation

protocol HighlightTextHepler: AnyObject {
    func getRange(with searchText: String, in mainText: String) -> NSRange?
    func getListRange(with searchText: String, in mainText: String) -> [NSRange]?
}

class RelativeHighlightSearchTextHelper: HighlightTextHepler {
    
    func getRange(with searchText: String, in mainText: String) -> NSRange? {
        if !searchText.isEmpty {
            let searchTexts = searchText.split(separator: " ")
            for item in searchTexts {
                if (mainText.lowercased().folded as NSString).contains(item.lowercased().folded) {
                    let range = (mainText.lowercased().folded as NSString).range(of: item.lowercased().folded)
                    return range
                }
            }
        }
        return nil
    }
    
    func getListRange(with searchText: String, in mainText: String) -> [NSRange]? {
        var ranges: [NSRange] = []
        let searchTexts = searchText.split(separator: " ").map{$0.lowercased().folded}
        let ptrn = searchTexts.joined(separator: "|")
        do {
            let regex = try NSRegularExpression(pattern: ptrn, options: [])
            let items = regex.matches(in: mainText.lowercased().folded, options: [],
                range: NSRange(location: 0, length: (mainText as NSString).length))
            ranges = items.map{$0.range}
        } catch {
            return nil
        }
        return ranges
    }
}
