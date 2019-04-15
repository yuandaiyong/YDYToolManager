//
//  AutoScrollView.swift
//  ProjectTest
//
//  Created by yuandaiyong on 2019/4/11.
//  Copyright © 2019 yuandaiyong. All rights reserved.
//

import UIKit
import EasyPeasy
@objc public protocol AutoScrollViewDelegate {
    
    func autoScrollViewCount(scrollView:AutoScrollView) -> Int
    func autoScrollView(scrollView:AutoScrollView,index:Int) -> UIView
    @objc optional func autoScrollView(scrollView:AutoScrollView,selectedIndex:Int) -> Void
}

public class AutoScrollView: UIView,UIScrollViewDelegate {
    
    /***public************/
    public var scrollInterval:TimeInterval = 5
    public var delegate : AutoScrollViewDelegate?
    public var isAutoScroll :Bool = true
    public var currentIndex : Int = 0
    
    /***private***********/
    private lazy var scrollView:UIScrollView = {
        var scroll = UIScrollView()
        scroll.backgroundColor = UIColor.clear
        scroll.bounces = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        scroll.delegate = self
        return scroll
    }()
    
    private var leftView : UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    
    private var midView : UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.black
        view.clipsToBounds = true
        return view
    }()
    
    private var rightView : UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    
    private var timer : Timer?
    private var midTap : UITapGestureRecognizer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.steupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.steupViews()
    }
    
    func steupViews() {
        self.addSubview(self.scrollView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.easy.layout(
            Left(0),
            Right(0),
            Top(0),
            Bottom(0)
        )
        
        self.reload()
    }
    

    
    
    public func reload() {
        
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        if let count = self.delegate?.autoScrollViewCount(scrollView: self) {
            if(count <= 1) {
                self.scrollView.contentSize = CGSize(width: self.bounds.size.width, height: self.bounds.size.height)
                self.scrollView.addSubview(self.midView)
                self.midView.easy.layout(
                    Left(0),
                    Top(0),
                    Width(self.frame.size.width),
                    Height(self.frame.size.height)
                )
            }else{
                self.scrollView.contentSize = CGSize(width: self.bounds.size.width * 3, height: self.bounds.size.height)
                self.scrollView.addSubview(self.leftView)
                self.scrollView.addSubview(self.midView)
                self.scrollView.addSubview(self.rightView)
                self.leftView.easy.layout(
                    Left(0),
                    Top(0),
                    Width(self.bounds.size.width),
                    Height(self.bounds.size.height)
                )
                self.midView.easy.layout(
                    Left(0).to(self.leftView,.right),
                    Top(0),
                    Width(self.bounds.size.width),
                    Height(self.bounds.size.height)
                )
                if(self.midTap != nil) {
                    self.midTap!.removeTarget(self, action: #selector(selectedImage))
                }
                self.midTap = UITapGestureRecognizer(target: self, action: #selector(selectedImage))
                self.midView.addGestureRecognizer(self.midTap!)
                
                self.rightView.easy.layout(
                    Left(0).to(self.midView,.right),
                    Top(0),
                    Width(self.bounds.size.width),
                    Height(self.bounds.size.height)
                )
                
                if let view = self.delegate?.autoScrollView(scrollView: self, index: count - 1) {
                    view.tag = 0x999
                    view.isUserInteractionEnabled = false
                    self.leftView.addSubview(view)
                    view.easy.layout(
                        Top(0),
                        Left(0),
                        Width(self.bounds.size.width),
                        Height(self.bounds.size.height)
                    )
                }
                if let view = self.delegate?.autoScrollView(scrollView: self, index: 0) {
                    view.tag = 0x999
                    view.isUserInteractionEnabled = false
                    self.midView.addSubview(view)
                    view.easy.layout(
                        Top(0),
                        Left(0),
                        Width(self.bounds.size.width),
                        Height(self.bounds.size.height)
                    )
                }
                if let view = self.delegate?.autoScrollView(scrollView: self, index: 1) {
                    view.tag = 0x999
                    view.isUserInteractionEnabled = false
                    self.rightView.addSubview(view)
                    view.easy.layout(
                        Top(0),
                        Left(0),
                        Width(self.bounds.size.width),
                        Height(self.bounds.size.height)
                    )
                }
                
                self.scrollView.setContentOffset(CGPoint(x: self.bounds.size.width, y: 0), animated: false)
            }
        }
        if(self.isAutoScroll) {
            if let time = self.timer {
                if(time.isValid) {
                    time.invalidate()
                }
            }
            self.timer = Timer.scheduledTimer(timeInterval: self.scrollInterval, target: self, selector: #selector(scrollToNextAuto), userInfo: nil, repeats: true)
        }
    
    }
    
    @objc func selectedImage() {
        self.delegate?.autoScrollView?(scrollView: self, selectedIndex: self.currentIndex)
    }
    
    @objc func scrollToNextAuto() {
        self.scrollView.setContentOffset(CGPoint(x: self.bounds.size.width * 2, y: 0), animated: true)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if(self.isAutoScroll) {
            if(self.timer!.isValid) {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
            let index = Int(self.scrollView.contentOffset.x / self.bounds.size.width)
            if(index == 2) {
                self.scrollNext()
            }else if(index == 0) {
                self.scrollPrevious()
            }
            if(self.isAutoScroll) {
                if let time = self.timer {
                    if(time.isValid) {
                        time.invalidate()
                    }
                }
                self.timer = Timer.scheduledTimer(timeInterval: self.scrollInterval, target: self, selector: #selector(scrollToNextAuto), userInfo: nil, repeats: true)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let index = Int(self.scrollView.contentOffset.x / self.bounds.size.width)
        if(index == 2) {
            self.scrollNext()
        }else if(index == 0) {
            self.scrollPrevious()
        }
        if(self.isAutoScroll) {
            if let time = self.timer {
                if(time.isValid) {
                    time.invalidate()
                }
            }
            self.timer = Timer.scheduledTimer(timeInterval: self.scrollInterval, target: self, selector: #selector(scrollToNextAuto), userInfo: nil, repeats: true)
        }
    }
    
    func scrollNext() {
        let leftView = self.leftView.viewWithTag(0x999)
        let midView = self.midView.viewWithTag(0x999)
        let rightView = self.rightView.viewWithTag(0x999)
        leftView?.removeFromSuperview()
        midView?.removeFromSuperview()
        rightView?.removeFromSuperview()
        self.currentIndex = self.currentIndex + 1
        self.leftView.addSubview(midView!)
        midView?.easy.layout(
            Top(0),
            Left(0),
            Bottom(0),
            Right(0)
        )
        self.midView.addSubview(rightView!)
        rightView?.easy.layout(
            Top(0),
            Left(0),
            Bottom(0),
            Right(0)
        )
        if let count = self.delegate?.autoScrollViewCount(scrollView: self) {
            if(self.currentIndex >= count) {
                self.currentIndex = 0
            }
            var index = self.currentIndex + 1
            if(index >= count) {
                index = 0
                
            }
            let view = self.delegate?.autoScrollView(scrollView: self, index: index)
            self.rightView.addSubview(view!)
            view?.isUserInteractionEnabled = false
            view?.tag = 0x999
            view?.easy.layout(
                Top(0),
                Left(0),
                Bottom(0),
                Right(0)
            )
        }
        self.scrollView.setContentOffset(CGPoint(x:self.bounds.size.width,y:0), animated: false)
    }
    
    func scrollPrevious() {
        let leftView = self.leftView.viewWithTag(0x999)
        let midView = self.midView.viewWithTag(0x999)
        let rightView = self.rightView.viewWithTag(0x999)
        leftView?.removeFromSuperview()
        midView?.removeFromSuperview()
        rightView?.removeFromSuperview()
        self.currentIndex = self.currentIndex - 1
        self.rightView.addSubview(midView!)
        midView?.easy.layout(
            Top(0),
            Left(0),
            Bottom(0),
            Right(0)
        )
        self.midView.addSubview(leftView!)
        leftView?.easy.layout(
            Top(0),
            Left(0),
            Bottom(0),
            Right(0)
        )
        if let count = self.delegate?.autoScrollViewCount(scrollView: self) {
            if(self.currentIndex < 0) {
                self.currentIndex = count - 1
            }
            var index = self.currentIndex - 1
            if(index < 0) {
                index = count - 1
            }
            let view = self.delegate?.autoScrollView(scrollView: self, index: index)
            self.leftView.addSubview(view!)
            view?.isUserInteractionEnabled = false
            view?.tag = 0x999
            view?.easy.layout(
                Top(0),
                Left(0),
                Bottom(0),
                Right(0)
            )
        }
        self.scrollView.setContentOffset(CGPoint(x:self.bounds.size.width,y:0), animated: false)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollNext()
    }
    
}
