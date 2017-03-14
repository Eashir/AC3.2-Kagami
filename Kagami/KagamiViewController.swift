//
//  KagamiViewController.swift
//  Kagami
//
//  Created by Eric Chang on 2/28/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase

struct Widget {
    
    var category : Category
    
    init(category: Category) {
        self.category = category
    }
    
    enum Category : Int {
        case weather, time, todos, quote
        
        var dockIcon : UIImage {
            switch self {
            case .weather: return UIImage(named: "cloud-icon")!
            case .time: return UIImage(named: "clock-icon")!
            case .todos: return UIImage(named: "checklist-icon")!
            case .quote: return UIImage(named: "quote")!
            }
        }
        
        var mirrorIcon : UIImage {
            switch self {
            case .weather: return UIImage(named: "Flash_Logo_01")!
            case .time: return UIImage(named: "Flash_Logo_01")!
            case .todos: return UIImage(named: "Flash_Logo_01")!
            case .quote: return UIImage(named: "Flash_Logo_01")!
            }
        }
        
        var description : String {
            switch self {
            case .weather: return "weather"
            case .time: return "time"
            case .todos: return "toDos"
            case .quote: return "quote"
            }
        }
    }
    let widgetView = UIView()
    let dockView = UIImageView()
    let mirrorView = UIImageView()
    
}



class KagamiViewController: UIViewController {
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    let userDefault = UserDefaults.standard
    var propertyAnimator: UIViewPropertyAnimator?
    
    var panRecognizer = UIPanGestureRecognizer()
    var tapRecognizer = UITapGestureRecognizer()
    
    var widgetArray = [Widget(category: .weather), Widget(category: .time), Widget(category: .todos), Widget(category: .quote)]
    var previousPoint: CGPoint?
    var widgetBeingEdited: UIView?
    
    var didTapWidget: () -> () = { }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "鏡"
        propertyAnimator = UIViewPropertyAnimator(duration: 0.75, dampingRatio: 0.77, animations: nil)
        
        setupViewHierarchy()
        
        ref = FIRDatabase.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        propertyAnimator = nil
    }
    
    
    // MARK: - Setup View Hierarchy & Constraints
    private func setupViewHierarchy() {
        
        view.backgroundColor = .white
        
        view.addSubview(mirrorImageView)
        view.addSubview(kagamiView)
        view.addSubview(iconContainerView)
        view.addSubview(weatherView)
        view.addSubview(timeView)
        view.addSubview(toDoView)
        view.addSubview(quoteView)
        
        weatherView.doneButton.addTarget(self, action: #selector(saveWeather), for: .touchDown)
        weatherView.cancelButton.addTarget(self, action: #selector(saveWeather), for: .touchDown)
        
        timeView.doneButton.addTarget(self, action: #selector(saveTime), for: .touchUpInside)
        
        toDoView.doneButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
        toDoView.cancelButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
        
        quoteView.doneButton.addTarget(self, action: #selector(saveQuote), for: .touchUpInside)
        quoteView.cancelButton.addTarget(self, action: #selector(saveQuote), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        // mirror view
        kagamiView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(iconContainerView.snp.top)
        }
        
        mirrorImageView.snp.makeConstraints({ (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(iconContainerView.snp.top)
        })
        
        // widget dock
        iconContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(60.0)
        }
        
        // instantiate Widgets
        for widget in widgetArray {
            
            let widgetView = widget.widgetView
            widget.dockView.image = widget.category.dockIcon
            widget.mirrorView.image = widget.category.mirrorIcon
            widgetView.addSubview(widget.dockView)
            widgetView.addSubview(widget.mirrorView)
            
            //            imageView.layer.borderColor = ColorPalette.blackColor.cgColor
            //            imageView.layer.borderWidth = 1.0
            widget.dockView.snp.makeConstraints({ (make) in
                make.trailing.bottom.top.leading.equalToSuperview()
            })
            widget.mirrorView.snp.makeConstraints({ (make) in
                make.trailing.bottom.top.leading.equalToSuperview()
            })
            
            widget.mirrorView.isHidden = true
            widgetView.alpha = 0.8
            widgetView.tag = widget.category.rawValue
            widgetView.accessibilityIdentifier = widget.category.description
            
            widgetView.addGestureRecognizer(setPanGestureRecognizer())
            widgetView.addGestureRecognizer(setTapRecognizer())
            widgetView.isUserInteractionEnabled = true
            self.view.addSubview(widgetView)
            iconContainerView.bringSubview(toFront: widgetView)
            
            let widgetDict = userDefault.dictionary(forKey: widgetView.accessibilityIdentifier!)
            
            
            if widgetDict != nil {
                
                if widgetDict?["onMirror"] as! Bool == true {
                    let x = widgetDict?["x"] as! CGFloat
                    let y = widgetDict?["y"] as! CGFloat
                    widgetView.subviews[0].isHidden = true
                    widgetView.subviews[1].isHidden = false
                    widgetView.snp.makeConstraints({ (make) in
                        make.center.equalTo(CGPoint(x: x, y: y))
                        make.height.width.equalTo(50.0)
                    })
                }
                else {
                    if widgetDict?["onMirror"] as! Bool == false {
                        widgetView.snp.makeConstraints({ (make) in
                            make.bottom.equalTo(iconContainerView.snp.bottom).offset(-5.0)
                            make.width.height.equalTo(50.0)
                            make.leading.equalTo(iconContainerView.snp.leading).offset((widgetView.tag * 50) + (8 * widgetView.tag) + 8)
                        })
                        
                    }
                }
            }
            else {
                widgetView.snp.makeConstraints { (make) in
                    make.bottom.equalTo(iconContainerView.snp.bottom).offset(-5.0)
                    make.width.height.equalTo(50.0)
                    make.leading.equalTo(iconContainerView.snp.leading).offset((widgetView.tag * 50) + (8 * widgetView.tag) + 8)
                }
            }
        }
        
        weatherView.snp.makeConstraints { (make) in
            make.center.equalTo(widgetArray[0].widgetView)
            make.size.equalTo(30.0)
        }
        
        timeView.snp.makeConstraints { (make) in
            make.center.equalTo(widgetArray[1].widgetView)
            make.size.equalTo(0.1)
        }
        
        toDoView.snp.makeConstraints { (make) in
            make.center.equalTo(widgetArray[2].widgetView)
            make.size.equalTo(0.1)
        }
        
        quoteView.snp.makeConstraints { (make) in
            make.center.equalTo(widgetArray[3].widgetView)
            make.size.equalTo(0.1)
        }
    }
    
    // add gestures
    func setPanGestureRecognizer() -> UIPanGestureRecognizer {
        
        panRecognizer = UIPanGestureRecognizer (target: self, action: #selector(self.wasDragged(_:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.cancelsTouchesInView = false
        return panRecognizer
    }
    
    func setTapRecognizer() -> UITapGestureRecognizer {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.wasTapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.require(toFail: panRecognizer)
        return tapRecognizer
    }
    
    func wasTapped(_ gesture: UITapGestureRecognizer) {
        
        let view = gesture.view!
        
        if gesture.state == .ended {
            
            previousPoint = CGPoint(x: view.frame.midX, y: view.frame.midY)
            
            switch view.accessibilityIdentifier! {
            case "weather":
                propertyAnimator?.addAnimations ({
                    self.weatherView.snp.remakeConstraints({ (make) in
                        make.height.width.equalToSuperview().multipliedBy(0.8)
                        make.center.equalToSuperview()
                    })
                    
                    self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
                    self.weatherView.layer.opacity = 1.0
                    
                    self.view.layoutIfNeeded()
                })
                
                widgetBeingEdited = widgetArray[0].widgetView
            case "time":
                propertyAnimator?.addAnimations ({
                    self.timeView.snp.remakeConstraints({ (make) in
                        make.height.width.equalToSuperview().multipliedBy(0.8)
                        make.center.equalToSuperview()
                    })
                    
                    self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
                    self.timeView.layer.opacity = 1.0
                    
                    self.view.layoutIfNeeded()
                })
                
                widgetBeingEdited = widgetArray[1].widgetView
            case "toDos":
                propertyAnimator?.addAnimations ({
                    self.toDoView.snp.remakeConstraints({ (make) in
                        make.height.width.equalToSuperview().multipliedBy(0.7)
                        make.center.equalToSuperview()
                    })
                    
                    self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
                    self.toDoView.layer.opacity = 1.0
                    
                    self.view.layoutIfNeeded()
                })
                
                widgetBeingEdited = widgetArray[2].widgetView
            case "quote":
                propertyAnimator?.addAnimations ({
                    self.quoteView.snp.remakeConstraints({ (make) in
                        make.height.width.equalToSuperview().multipliedBy(0.8)
                        make.center.equalToSuperview()
                    })
                    
                    self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
                    self.quoteView.layer.opacity = 1.0
                    
                    self.view.layoutIfNeeded()
                })
                
                widgetBeingEdited = widgetArray[3].widgetView
            default:
                break
            }
            propertyAnimator?.startAnimation()
        }
    }
    
    func wasDragged(_ gesture: UIPanGestureRecognizer) {
        let widgetView = gesture.view!
        let translation = gesture.translation(in: self.view)
        
        widgetView.center = CGPoint(x: widgetView.center.x + translation.x , y: widgetView.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
        
        //TODO: - MATH -- min > kagami.min && max < kagami.max
        
        if gesture.state == .began {
            
            dump("Parent View \(self.view.subviews.count)")
            dump("Kagami View \(self.kagamiView.subviews.count)")
            dump(widgetView)
        }
        
        if gesture.state == .changed {
            let centerOfWidget = self.kagamiView.convert(widgetView.center, from: widgetView.superview)
            
            if kagamiView.bounds.contains(centerOfWidget) {
                dump(widgetView.subviews)
                print("We in the mirror")
                widgetView.subviews[0].isHidden = true
                widgetView.subviews[1].isHidden = false
            } else {
                widgetView.subviews[0].isHidden = false
                widgetView.subviews[1].isHidden = true
            }
        }
        
        if gesture.state == .ended {
            
            let centerOfWidget = self.kagamiView.convert(widgetView.center, from: widgetView.superview)
            print(kagamiView.bounds.contains(centerOfWidget))
            let originOfWidget = self.kagamiView.convert(widgetView.frame.origin, from: widgetView.superview)
            
            if kagamiView.bounds.contains(centerOfWidget) {
                // self.kagamiView.addSubview(widgetView)
                widgetView.snp.remakeConstraints({ (make) in
                    make.center.equalTo(centerOfWidget)
                    make.height.width.equalTo(50.0)
                })
                self.view.layoutSubviews()
                userDefault.set(["onMirror" : true, "x" : centerOfWidget.x, "y" : centerOfWidget.y], forKey: widgetView.accessibilityIdentifier!)
            }
            else {
                widgetView.snp.remakeConstraints  { (make) in
                    make.bottom.equalTo(iconContainerView.snp.bottom).offset(-5.0)
                    make.width.height.equalTo(50.0)
                    make.leading.equalTo(iconContainerView.snp.leading).offset((widgetView.tag * 50) + (8 * widgetView.tag) + 8)
                }
                self.view.layoutSubviews()
                userDefault.set(["onMirror" : false, "x" : centerOfWidget.x, "y" : centerOfWidget.y], forKey: widgetView.accessibilityIdentifier!)
                ref.child(widgetView.accessibilityIdentifier!).updateChildValues(["onMirror" : false])
            }
            
            for widget in widgetArray {
                let widgetOrigin = self.kagamiView.convert(widget.widgetView.frame.origin, from: widgetView.superview)
                if self.kagamiView.bounds.contains(centerOfWidget) {
                    switch widget.category {
                    case .weather:
                        let weatherNode = ref.child("weather")
                        weatherNode.updateChildValues(["x" : (widgetOrigin.x / kagamiView.frame.maxX) , "y" : (widgetOrigin.y / kagamiView.bounds.maxY), "onMirror" : true])
                    case .time:
                        let timeNode = ref.child("time")
                        timeNode.updateChildValues(["x" : (widgetOrigin.x / kagamiView.frame.maxX) , "y" : (widgetOrigin.y / kagamiView.bounds.maxY), "onMirror" : true])
                        
                    case .todos:
                        
                        let toDoNode = ref.child("toDos")
                        toDoNode.updateChildValues(["x" : (widgetOrigin.x / kagamiView.frame.maxX) , "y" : (widgetOrigin.y / kagamiView.bounds.maxY), "onMirror" : true])
                        
                    case .quote:
                        
                        let toDoNode = ref.child("quote")
                        toDoNode.updateChildValues(["x" : (widgetOrigin.x / kagamiView.frame.maxX) , "y" : (widgetOrigin.y / kagamiView.bounds.maxY), "onMirror" : true])
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Save custom settings
    //TODO: - Migrate to seperate file
    func saveWeather(_ sender: UIButton) {
        guard let view = widgetBeingEdited else { return }
        
        if sender == weatherView.doneButton {
            // save to firebase
            print("weather done works")
        }
        
        propertyAnimator?.addAnimations {
            
            self.weatherView.snp.remakeConstraints({ (make) in
                make.size.equalTo(0.1)
                make.center.equalTo(view.snp.center)
            })
            
            self.view.layoutIfNeeded()
        }
        
        self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        propertyAnimator?.startAnimation()
    }
    
    func saveTime(_ sender: UIButton) {
        guard let view = widgetBeingEdited else { return }
        
        if sender == timeView.doneButton {
            // save to firebase
            print("time done works")
        }
        
        propertyAnimator?.addAnimations {
            
            self.timeView.snp.remakeConstraints({ (make) in
                make.size.equalTo(0.1)
                make.center.equalTo(view.snp.center)
            })
            
            self.view.layoutIfNeeded()
        }
        //TODO: backgroundColor inside animations will flash black screen for 0.5 seconds
        self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        propertyAnimator?.startAnimation()
    }
    
    func saveToDo(_ sender: UIButton) {
        guard let view = widgetBeingEdited else { return }
        
        if sender == toDoView.doneButton {
            // save to firebase
            print("todo done works")
        }
        
        propertyAnimator?.addAnimations {
            
            self.toDoView.snp.remakeConstraints({ (make) in
                make.size.equalTo(0.1)
                make.center.equalTo(view.snp.center)
            })
            
            self.view.layoutIfNeeded()
        }
        self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        propertyAnimator?.startAnimation()
    }
    func saveQuote(_ sender: UIButton) {
        guard let view = widgetBeingEdited else { return }
        
        if sender == quoteView.doneButton {
            print("quote done buttonworks")
        }
        
        propertyAnimator?.addAnimations {
            
            self.quoteView.snp.remakeConstraints({ (make) in
                make.size.equalTo(0.1)
                make.center.equalTo(view.snp.center)
            })
            
            self.view.layoutIfNeeded()
        }
        self.kagamiView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        propertyAnimator?.startAnimation()
    }
    
    // MARK: - Lazy Instantiates
    
    lazy var kagamiView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2.0
        return view
    }()
    
    lazy var mirrorImageView: UIImageView = {
        let image = UIImage(named: "mirror2")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var iconContainerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = ColorPalette.whiteColor.withAlphaComponent(5)
        return view
    }()
    
    lazy var weatherView: WeatherView = {
        let view = WeatherView()
        view.layer.opacity = 0.0
        view.clipsToBounds = true
        return view
    }()
    
    lazy var timeView: TimeView = {
        let view = TimeView()
        view.layer.opacity = 0.0
        view.clipsToBounds = true
        return view
    }()
    
    lazy var toDoView: ToDoView = {
        let view = ToDoView()
        view.layer.opacity = 1.0
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        return view
    }()
    
    lazy var quoteView: QuoteView = {
        let view = QuoteView()
        view.layer.opacity = 1.0
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        return view
    }()
}

// Ignore for now
class CollidingViewBehavior: UIDynamicBehavior  {
    
    override init() {}
    
    convenience init(items: [UIDynamicItem]) {
        self.init()
        
        let collisionBehavior = UICollisionBehavior(items: items)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        self.addChildBehavior(collisionBehavior)
        
        let elasticBehavior = UIDynamicItemBehavior(items: items)
        elasticBehavior.elasticity = 0.0
        self.addChildBehavior(elasticBehavior)
        
    }
}



