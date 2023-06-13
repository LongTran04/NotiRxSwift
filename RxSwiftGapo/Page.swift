
import UIKit
import RxSwift
import RxCocoa
import Action

extension Reactive where Base: IView {
    
    public typealias ViewModelElement = Base.ViewModelElement
    
    /**
     Custom binder for viewModel, can be any type
     
     This could be handy for binding a sub viewModel
     */
    public var viewModel: Binder<ViewModelElement?> {
        return Binder(base) { $0.viewModel = $1 }
    }
}

open class SFPage<VM: IViewModel>: UIViewController, IView, ITransitionView {
    
    public var disposeBag: DisposeBag? = DisposeBag()
    private var hudBag: DisposeBag? = DisposeBag()
    
    private var _viewModel: VM?
    public var viewModel: VM? {
        get { return _viewModel }
        set {
            if _viewModel != newValue {
                disposeBag = DisposeBag()
                
                _viewModel = newValue
                viewModelChanged()
            }
        }
    }
    
    public var anyViewModel: Any? {
        get { return _viewModel }
        set { viewModel = newValue as? VM }
    }
    
    public init(viewModel: VM? = nil) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        initialize()
        viewModelChanged()
    }
    
    /**
     Subclasses override this method to initialize UIs.
     
     This method is called in `viewDidLoad`. So try not to use `viewModel` property if you are
     not sure about it
     */
    open func initialize() {}
    
    /**
     Subclasses override this method to create data binding between view and viewModel.
     
     This method always happens, so subclasses should check if viewModel is nil or not. For example:
     ```
     guard let viewModel = viewModel else { return }
     ```
     */
    open func bindViewAndViewModel() {}
    
    /**
     Subclasses override this method to remove all things related to `DisposeBag`.
     */
    open func destroy() {
        disposeBag = DisposeBag()
        hudBag = DisposeBag()
        viewModel?.destroy()
    }
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: true, completion: completion)
    }
}
