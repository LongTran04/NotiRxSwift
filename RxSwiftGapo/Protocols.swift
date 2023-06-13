

import UIKit
import RxSwift
import RxCocoa

/// Destroyable type for handling dispose bag and destroy it
public protocol IDestroyable: AnyObject {
    
    var disposeBag: DisposeBag? { get set }
    func destroy()
}

/// TransitionView type to create custom transitioning between pages
public protocol ITransitionView: AnyObject {

}

/// AnyView type for helping assign any viewModel to any view
public protocol IAnyView: AnyObject {
    
    /**
     Any value assign to this property will be delegate to its correct viewModel type
     */
    var anyViewModel: Any? { get set }
}

/// Base View type for the whole library
public protocol IView: IAnyView, IDestroyable {
    
    associatedtype ViewModelElement
    
    var viewModel: ViewModelElement? { get set }
    
    func initialize()
    func bindViewAndViewModel()
}

// MARK: - Viewmodel protocols

/// Base generic viewModel type, implement Destroyable and Equatable
public protocol IGenericViewModel: IDestroyable, Equatable {
    
    associatedtype ModelElement
    
    var model: ModelElement? { get set }
    
    init(model: ModelElement?)
}

/// Base ViewModel type for Page (UIViewController), View (UIVIew)
public protocol IViewModel: IGenericViewModel {
    
}

public protocol IListViewModel: IViewModel {
    
    associatedtype CellViewModelElement: IGenericViewModel
    
    var itemsSource: ReactiveCollection<CellViewModelElement> { get }
    var rxSelectedItem: BehaviorRelay<CellViewModelElement?> { get }
    var rxSelectedIndex: BehaviorRelay<IndexPath?> { get }
    
    func selectedItemDidChange(_ cellViewModel: CellViewModelElement)
}
