
# FullScreenPopGesture_Swift_Demo

![demo.png](https://github.com/dongxiexidu/FullScreenPopGesture/blob/master/demo.gif)

### 1.Swift运行时使用入口
```
extension UIApplication {
    // 内联函数
    private static let runOnce: Void = {
        
        NothingToSeeHere.harmlessFunction()
    }()
    
    // 在applicationDidFinishLaunching方法之前调用
    override open var next: UIResponder? {
       
        UIApplication.runOnce
        return super.next
    }
}
```
1.1获取所有的类
```
static func harmlessFunction() {

    // 打印 11930 获取所有的类数量
    let typeCount = Int(objc_getClassList(nil, 0))
    
    // 在Swift中无类型的指针，原始内存可以用UnsafeRawPointer 和UnsafeMutableRawPointer来表示
    // 定义一个存放类的数组,capacity指定分配内存大小
    // 不提供自动内存管理，没有类型安全性
    let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
    let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
    // 获取所有的类,存放到数组types
    objc_getClassList(autoreleasingTypes, Int32(typeCount))
    
    // 如果该类实现了SelfAware协议，那么调用awake方法
    for index in 0 ..< typeCount {
        (types[index] as? SelfAware.Type)?.awake()
    }
    //        types.deallocate(capacity: typeCount)
    // 释放
    types.deallocate()
}
```
1.2 定义协议
```
protocol SelfAware: class {
    static func awake()
}
```
1.3 给`UIViewController`添加`extension`,并遵守`SelfAware`协议,在实现协议的`awake()`方法中交换`viewWillAppear(_:)`与`viewWillDisappear(_:)`方法和`UINavigationController`的`pushViewController(_:animated:)`
```
extension UIViewController:SelfAware {
    static func awake() {
        UIViewController.classInit()
        UINavigationController.classInitial()
    }
    
    static func classInit() {
        swizzleMethod
    }
    
    @objc fileprivate func swizzled_viewWillAppear(_ animated: Bool) {
        swizzled_viewWillAppear(animated)
        if self.dx_willAppearInjectBlock != nil {
            self.dx_willAppearInjectBlock!(self,animated)
        }
    }
    
    @objc  func swizzled_viewWillDisAppear(_ animated: Bool) {
        swizzled_viewWillDisAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let viewcontroller = self.navigationController?.viewControllers.last
            if (viewcontroller != nil && viewcontroller?.dx_navigationBarHidden == nil) {
                self.navigationController?.setNavigationBarHidden(false, animated: false);
            }
        }
    }
    
    private static let swizzleMethod: Void = {
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(swizzled_viewWillAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
        
        let originalSelector1 = #selector(viewWillDisappear(_:))
        let swizzledSelector1 = #selector(swizzled_viewWillDisAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector1, swizzledSelector: swizzledSelector1)
    }()
    
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        guard (originalMethod != nil && swizzledMethod != nil) else {
            return
        }
        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}
```

1.4 `UINavigationController`的`pushViewController(_:animated:)`和`dx_pushViewController(_:animated:)`的交换方法

全屏返回的方法核心就在这里处理
```
extension UINavigationController {
    static func classInitial() {
        swizzleMethod
    }
    
    private static let swizzleMethod: Void = {
        let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledSelector = #selector(dx_pushViewController)
        swizzlingForClass(UINavigationController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()
    
    @objc fileprivate func dx_pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard let contains = self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(self.dx_fullScreenPopGestureRecognizer!) else { return }
        
        if !contains {
            guard let dx_fullScreenPopGestureRecognizer = self.dx_fullScreenPopGestureRecognizer else { return }
            guard let systemGesture = interactivePopGestureRecognizer else { return  }
            guard let gestureView = systemGesture.view else { return  }
            gestureView.addGestureRecognizer(dx_fullScreenPopGestureRecognizer)
            let targets = systemGesture.value(forKey: "targets") as! [NSObject]
            guard let targetObj = targets.first else { return }
            guard let target = targetObj.value(forKey: "target") else { return }
            let action = Selector(("handleNavigationTransition:"))
            dx_fullScreenPopGestureRecognizer.delegate = self.dx_popGestureRecognizerDelegate
            dx_fullScreenPopGestureRecognizer.addTarget(target, action: action)
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        self.dx_setupVCNavigationBarAppearanceIfNeeded(appearingVC: viewController)
        if !(self.viewControllers.contains(viewController)) {
            self.dx_pushViewController(viewController, animated: animated)
        }
    }
    
    fileprivate func dx_setupVCNavigationBarAppearanceIfNeeded(appearingVC:UIViewController) {
        weak var weakSelf = self
        let block: DXVCWillAppearInjectBlock = {(_ vc: UIViewController?, _ animated: Bool) -> Void in
            let strongSelf = weakSelf
            if (strongSelf != nil) {
                strongSelf?.setNavigationBarHidden(vc?.dx_navigationBarHidden != nil, animated: animated)
            }
        }
        
        appearingVC.dx_willAppearInjectBlock = block
        guard let disAppearingVC = self.viewControllers.last else { return }
        if disAppearingVC.dx_willAppearInjectBlock == nil {
            disAppearingVC.dx_willAppearInjectBlock = block
        }
    }
    
    fileprivate var dx_popGestureRecognizerDelegate: DXFullScreenPopGestureRecognizerDelegate? {
        get {
            var delegate = objc_getAssociatedObject(self, RuntimeKey.dx_popGestureRecognizerDelegate!) as? DXFullScreenPopGestureRecognizerDelegate
            if delegate == nil {
                delegate = DXFullScreenPopGestureRecognizerDelegate()
                delegate?.navigationController = self
                objc_setAssociatedObject(self, RuntimeKey.dx_popGestureRecognizerDelegate!, delegate!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return delegate!
        }
    }
    
    fileprivate var dx_fullScreenPopGestureRecognizer : UIPanGestureRecognizer? {
        get {
            var pan = objc_getAssociatedObject(self, RuntimeKey.dx_fullScreenPopGestureRecognizer!) as? UIPanGestureRecognizer
            if pan == nil {
                pan = UIPanGestureRecognizer()
                pan!.maximumNumberOfTouches = 1
                objc_setAssociatedObject(self, RuntimeKey.dx_fullScreenPopGestureRecognizer!, pan!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return pan!
        }
    }
}
```
1.4 给UIViewController通过运行时添加属性,**方便外界控制以下权限**是否开启侧滑(默认true),是否隐藏导航栏(默认false),允许侧滑的手势范围(默认全屏)
```
typealias DXVCWillAppearInjectBlock = (_ vc: UIViewController?, _ animated: Bool) -> Void

extension  UIViewController {
    
    // MARK:- RuntimeKey   动态绑属性
    struct RuntimeKey {
        
        // 在Swift中无类型的指针，原始内存可以用UnsafeRawPointer 和UnsafeMutableRawPointer来表示
        // A raw pointer for accessing untyped data 用于访问非类型数据的原始指针
        // init(bitPattern:) 从指定地址创建一个新的原始指针，指定为位模式
        
        // 哈希: http://swifter.tips/hash/
        // 比如 Int 的 hashValue 就是它本身：
        // print("dx_popDisabled".hashValue) 402467026446327185
        static let dx_popDisabled = UnsafeRawPointer.init(bitPattern: "dx_popDisabled".hashValue)
        
        static let dx_navigationBarHidden = UnsafeRawPointer.init(bitPattern: "dx_navigationBarHidden".hashValue)
        static let dx_allowPopDistance = UnsafeRawPointer.init(bitPattern: "dx_allowPopDistance".hashValue)
        static let dx_fullScreenPopGestureRecognizer = UnsafeRawPointer.init(bitPattern: "dx_fullScreenPopGestureRecognizer".hashValue)
        static let dx_willAppearInjectBlock = UnsafeRawPointer.init(bitPattern: "dx_willAppearInjectBlock".hashValue)
        static let dx_popGestureRecognizerDelegate = UnsafeRawPointer.init(bitPattern: "dx_popGestureRecognizerDelegate".hashValue)
    }
    
    // MARK:- 是否开启侧滑，默认true
    public var dx_popDisabled: Bool? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_popDisabled!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_popDisabled!) as? Bool
        }
    }
    
    // MARK:- 是否隐藏导航栏，默认false
    public var dx_navigationBarHidden: Bool? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_navigationBarHidden!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_navigationBarHidden!) as? Bool
        }
    }
    
    // MARK:- 允许侧滑的手势范围。默认全屏
    public var dx_allowPopDistance: CGFloat? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_allowPopDistance!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_allowPopDistance!) as? CGFloat
        }
    }
    
    var dx_willAppearInjectBlock:DXVCWillAppearInjectBlock? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.dx_willAppearInjectBlock!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_willAppearInjectBlock!) as? DXVCWillAppearInjectBlock
        }
    }
    
}
```

1.5 自定义一个继承自`UIGestureRecognizerDelegate`手势类,用于处理是否开启全屏侧滑,开启返回侧滑的距离
```
class DXFullScreenPopGestureRecognizerDelegate:NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    // 与OC不同的是，这里不能直接把UIGestureRecognizerDelegate写成是UIPanGestureRecognizer的，必须得是UIGestureRecognizer。
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
       // let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        
        if (self.navigationController?.viewControllers.count)! <= 1 {
            return false
        }
        
        let topVC: UIViewController? = navigationController?.viewControllers.last
        if let disabled = topVC?.dx_popDisabled  {
            if disabled {
                return false
            }
        }
        
        let beginLocation: CGPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
        let allowedDistance: CGFloat? = topVC?.dx_allowPopDistance
        if (allowedDistance ?? 0.0) > 0 && beginLocation.x > (allowedDistance ?? 0.0) {
            return false
        }
        
        let isTransitioning = navigationController?.value(forKey: "_isTransitioning") as? Bool
        
        if let t = isTransitioning {
            if t {
                return false
            }
        }
        
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let isLeftToRight: Bool = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if (translation.x * multiplier) <= 0 {
            return false
        }
        
        return true
    }

}
```

原githud地址![FullScreenPopGesture](https://github.com/xxxbryant/FullScreenPopGesture)
