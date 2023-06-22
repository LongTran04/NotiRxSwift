//
//  HighlightSearchTextHelper.swift
//  NotificationRxSwift
//
//  Created by Long Tran on 21/06/2023.
//

import Foundation

class HighlightSearchTextHelper {
    var searchText: String? = nil
    var mainText: String = ""
    var range: NSRange? = nil
    var ranges: [NSRange]? = nil
    
    init(searchText: String? = nil, mainText: String) {
        self.searchText = searchText
        self.mainText = mainText
        self.range = getRangeSearchText()
        self.ranges = rangesForSearchText()
    }
    
    func getRangeSearchText() -> NSRange? {
        if let searchText = searchText, !searchText.isEmpty {
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
    
    func rangesForSearchText() -> [NSRange]? {
        var ranges: [NSRange] = []
        guard let searchText = searchText else { return nil }
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
