import UIKit

private struct Settings {
    static let animationDuration: TimeInterval = 5
    static let itemAlpha: CGFloat = 0.7
    static let scale: CGFloat = 3
    static let animationOptions: UIView.AnimationOptions = [.autoreverse, .repeat, .curveEaseInOut]
}

private class ItemView: UIView {
    var animation: CGAffineTransform?
    private lazy var gradient: CAGradientLayer = {
        let g = CAGradientLayer()
        let color1 = UIColor(red: 121/255, green: 210/255, blue: 162/255, alpha: 1)
        let color2 = UIColor(red: 81/255, green: 162/255, blue: 171/255, alpha: 1)
        g.colors = [color1.cgColor, color2.cgColor]
        return g
    }()
    
    func applyAnimation() {
        if let animation = animation {
            transform = animation
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            gradient.bounds = bounds
            gradient.render(in: context)
        }
    }
}

private class ItemGroupView: UIView {
    let itemCount: Int
    private var items = [ItemView]()
    
    internal init(itemCount: Int) {
        self.itemCount = itemCount
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupSubviews() {
        for _ in 0...itemCount {
            let item = ItemView()
            item.alpha = Settings.itemAlpha
            addSubview(item)
            items.append(item)
        }
    }
    
    private func setupAnimation() {
        let circlePoint: Float = (2.0 * Float.pi) / Float(itemCount)
        let radius: Float = Float(frame.width / 5.8)
        
        for (index, item) in items.enumerated() {
            let x = cosf(circlePoint * Float(index)) * radius
            let y = sinf(circlePoint * Float(index)) * radius
            
            let transform = CGAffineTransform(scaleX: Settings.scale, y: Settings.scale)
            let translate = CGAffineTransform(translationX: CGFloat(x), y: CGFloat(y))
            let animation = transform.concatenating(translate)
            item.animation = animation
        }
    }
    
    private func setupFrame() {
        self.items.forEach {
            $0.frame = CGRect(x: 0, y: 0, width: frame.width / 8, height: frame.height / 8)
            $0.layer.cornerRadius = $0.frame.width / 2
            $0.layer.masksToBounds = true
            $0.center = center
        }
    }
    
    func animate() {
        UIView.animate(withDuration: Settings.animationDuration, delay: 0, options: Settings.animationOptions, animations: {
            self.items.forEach {
                $0.applyAnimation()
            }
        }, completion: nil)
    }
    
    override var frame: CGRect {
        didSet {
            setupFrame()
            setupAnimation()
        }
    }
}

class BreatheView: UIView {
    let itemCount: Int
    private lazy var item: ItemGroupView = {
        return ItemGroupView(itemCount: itemCount)
    }()
    
    internal init(itemCount: Int) {
        self.itemCount = itemCount
        super.init(frame: .zero)
        addSubview(item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            item.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
    }
    
    func animate() {
        UIView.animate(withDuration: Settings.animationDuration, delay: 0, options: Settings.animationOptions, animations: {
            self.item.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: nil)
        item.animate()
    }
}
