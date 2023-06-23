//
//  ViewController.swift
//  NotificationRxSwift
//
//  Created by Long Tran on 08/06/2023.
//

import UIKit
import RxCocoa
import RxSwift

class HomeViewController: SFPage<HomeViewModel>, UISearchBarDelegate {
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    let homeViewModel = HomeViewModel()
    var tableBinding: HomeTableViewBindingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = homeViewModel
    }
    
    override func initialize() {
        super.initialize()
        searchView.isHidden = true
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.delegate = self
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        tableBinding = HomeTableViewBindingHelper(tableView: tableView, viewModel: viewModel)
        let exitBtnObservable: Observable<Void> = exitBtn.rx.tap.asObservable()
        let showSearchViewBySearchBtn = searchBtn.rx.tap.map { _ in false }
        let hideSearchViewByExitBtn = exitBtnObservable.map { _ in true }
        Observable.merge(showSearchViewBySearchBtn, hideSearchViewByExitBtn) ~> searchView.rx.isHidden => disposeBag
        searchBar.rx.text.bind(to: viewModel.rxSearchAction) => disposeBag
        exitBtnObservable.subscribe(onNext: { [weak self] in
            self?.resetSearchView()
        }) => disposeBag
    }
    
    private func resetSearchView() {
        searchBar.text = ""
        viewModel?.rxSearchAction.accept("")
    }
    
}

class HomeTableViewBindingHelper: TableBindingHelper<HomeViewModel> {
    override func initialize() {
        tableView.register(UINib(nibName: "NotiTableViewCell", bundle: nil), forCellReuseIdentifier: NotiTableViewCell.identifier)
    }
    
    override func cellIdentifier(_ cellViewModel: TableBindingHelper<HomeViewModel>.CVM) -> String {
        return NotiTableViewCell.identifier
    }
}

class HomeViewModel: ListViewModel<NotiModel, NotiCellViewModel> {
    let rxSearchAction = BehaviorRelay<String?>(value: nil)
    
    override func react() {
        model = readJSONFile()
        itemsSource.reset([getNotiCellViewModels(models: model?.data ?? [])])
        rxSearchAction.subscribe(onNext: { [weak self] text in
            self?.searchAction(searchText: text ?? "")
        }) => disposeBag
    }
    
    func getNotiCellViewModels(models: [Noti]) -> [NotiCellViewModel] {
        return models.map { NotiCellViewModel(model: $0) }
    }
    
    func readJSONFile() -> NotiModel {
        var notiModel = NotiModel(data: [])
        do {
          if let bundlePath = Bundle.main.path(forResource: "noti", ofType: "json"),
          let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
              let decoder = JSONDecoder()
              notiModel = try decoder.decode(NotiModel.self, from: jsonData)
          }
        } catch {
          print(error)
        }
        return notiModel
    }
    
    func getSearchResult(_ searchText: String) -> [NotiCellViewModel] {
        if searchText.isEmpty {
            return model?.data.map {
                NotiCellViewModel(model: $0, highlightTextHepler: RelativeHighlightSearchTextHelper())
            } ?? [] }
        return model?.data.filter {
            let listSearchText = searchText.split(separator: " ")
            for item in listSearchText {
                if $0.message.text.lowercased().folded.contains(item.lowercased().folded) {
                    return true
                }
            }
            return false
        }.map { NotiCellViewModel(model: $0, highlightTextHepler: RelativeHighlightSearchTextHelper()) } ?? []
    }
    
    func searchAction(searchText: String) {
        let cellViewModels = getSearchResult(searchText)
        for cvm in cellViewModels {
            cvm.rxSearchText.accept(searchText)
        }
        itemsSource.reset([cellViewModels], animated: false)
    }
    
}

// MARK: - Extension
extension String {
    var folded: String {
        return self.folding(options: .diacriticInsensitive, locale: nil)
            .replacingOccurrences(of: "đ", with: "d")
            .replacingOccurrences(of: "Đ", with: "D")
    }
}
