//
//  NotiTableViewCell.swift
//  NotificationRxSwift
//
//  Created by Long Tran on 08/06/2023.
//

import UIKit
import RxCocoa
import RxSwift

class NotiTableViewCell: TableCell<NotiCellViewModel> {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var notiTitleLabel: UILabel!
    @IBOutlet weak var notiTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.circleImage()
        actionImageView.circleImage()
    }
    
    override func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.rxUserImage.subscribe(onNext: { [weak self] urlString in
            self?.userImageView.load(from: urlString ?? "")
        }) => disposeBag
        viewModel.rxActionImage.subscribe(onNext: { [weak self] urlString in
            self?.actionImageView.load(from: urlString ?? "")
        }) => disposeBag
        viewModel.rxNotiTitle ~> notiTitleLabel.rx.text => disposeBag
        viewModel.rxNotiTime ~> notiTimeLabel.rx.text => disposeBag
        viewModel.rxBackgroundColor ~> rx.backgroundColor => disposeBag
        viewModel.rxHighlight.subscribe(onNext: { [weak self] _ in
            self?.highlighLabel()
        }) => disposeBag
    }
    
    func highlighLabel() {
        guard let vm = viewModel, let model = vm.model, let searchText = vm.rxSearchText.value, let title = vm.rxNotiTitle.value else { return }
        let highlightText = vm.getHighlightText(model.message)
        let rangeHighlight = vm.rangesForHighlight(highlightText, in: title)
        let rangesSearchText = vm.rangesForSearchText(searchText, in: title) ?? []
        notiTitleLabel.highlight(rangesSearchText: rangesSearchText, rangeHighlight: rangeHighlight)
    }
}

class NotiCellViewModel: CellViewModel<Noti> {
    let rxUserImage = BehaviorRelay<String?>(value: nil)
    let rxActionImage = BehaviorRelay<String?>(value: nil)
    let rxNotiTitle = BehaviorRelay<String?>(value: nil)
    let rxNotiTime = BehaviorRelay<String?>(value: nil)
    let rxBackgroundColor = BehaviorRelay<UIColor?>(value: nil)
    let rxHighlight = BehaviorRelay<Void?>(value: nil)
    let rxSearchText = BehaviorRelay<String?>(value: nil)
    
    override func react() {
        guard let model = model else { return }
        rxUserImage.accept(model.image)
        rxActionImage.accept(model.icon)
        rxNotiTitle.accept(model.message.text)
        rxNotiTime.accept(model.createdAt.toTimeText())
        rxBackgroundColor.accept(getBackgroundColor(model.status))
        rxSearchText.subscribe(onNext: { [weak self] _ in
            self?.setNewNotiTitle(title: self?.rxNotiTitle.value ?? "")
        }) => disposeBag
        rxHighlight.accept(())
    }
    
    func getRangeSearchText() -> NSRange? {
        if let searchText = rxSearchText.value,  let title = rxNotiTitle.value, !searchText.isEmpty {
            let searchTexts = searchText.split(separator: " ")
            for item in searchTexts {
                if (title.lowercased().folded as NSString).contains(item.lowercased().folded) {
                    let range = (title.lowercased().folded as NSString).range(of: item.lowercased().folded)
                    return range
                }
            }
        }
        return nil
    }
    
    func setNewNotiTitle(title: String)  {
        if let range = getRangeSearchText(), range.location > 30 {
            let newTitle = title.subString(from: range.location - 20, to: title.count)
            rxNotiTitle.accept(newTitle)
        }
    }
    
    func getBackgroundColor(_ status: String) -> UIColor {
        let backgroundColor: UIColor = (status == "unread") ? .backgroundColor : .white
        return backgroundColor
    }
    
    func getHighlightText(_ message: Message) -> [String] {
        return message.highlights.map {
            return message.text.subString(from: $0.offset, to: $0.offset + $0.length)
        }
    }
    
    func rangesForHighlight(_ texts: [String], in mainText: String) -> [NSRange] {
        return texts.map {(mainText.lowercased().folded as NSString).range(of: $0.lowercased().folded)}
    }
    
    func rangesForSearchText(_ searchText: String, in mainText: String) -> [NSRange]? {
        var ranges: [NSRange] = []
        let searchTexts = searchText.split(separator: " ").map{$0.lowercased().folded}
        let ptrn = searchTexts.joined(separator: "|")
        do {
            let regex = try NSRegularExpression(pattern: ptrn, options: [])
            let items = regex.matches(in: mainText.lowercased().folded, options: [], range: NSRange(location: 0, length: (mainText as NSString).length))
            ranges = items.map{$0.range}
        } catch {
            return nil
        }
        return ranges
    }
    
}

// MARK: - Extension
extension Int {
    func toTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, HH:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return formatter.string(from: date)
    }
}

extension String {
    func subString(from: Int, to: Int) -> String {
       let startIndex = self.index(self.startIndex, offsetBy: from)
       let endIndex = self.index(self.startIndex, offsetBy: to)
       return String(self[startIndex..<endIndex])
    }
}

extension UIColor {
    static let highlightColor = UIColor(red: 0.23, green: 0.71, blue: 0.48, alpha: 1.00)
    static let backgroundColor = UIColor(red: 0.93, green: 0.97, blue: 0.91, alpha: 1.00)
}

var imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func circleImage() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    func load(from urlString: String) {
        if let image = imageCache.object(forKey: urlString as NSString) {
            self.image = image
            return
        }
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UILabel {
    func highlight(rangesSearchText: [NSRange], rangeHighlight: [NSRange]) {
        guard let mainText = self.text else { return }
        let highlightAttributedString = NSMutableAttributedString(string: mainText)
        for range in rangeHighlight {
            highlightAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: range)
        }
        for range in rangesSearchText {
            highlightAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.highlightColor, range: range)
            highlightAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: range)
        }
        self.attributedText = highlightAttributedString
    }
}
