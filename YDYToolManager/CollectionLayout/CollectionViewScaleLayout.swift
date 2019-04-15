//
//  CollectionViewScaleLayout.swift
//  ProjectTest
//
//  Created by yuandaiyong on 2019/4/3.
//  Copyright © 2019 yuandaiyong. All rights reserved.
//

import UIKit

public class CollectionViewScaleLayout: UICollectionViewFlowLayout {
    
    // 常量
    private struct InnerConstant {
        static let MinScaleW: CGFloat = 0.9
        static let MinScaleH: CGFloat = 0.4
    }
    
    // width最小的缩放比
    public var minScaleW = InnerConstant.MinScaleW
    // height最小的缩放比
    public var minScaleH = InnerConstant.MinScaleH
    
    public override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
        let inset = (collectionView!.frame.size.width - self.itemSize.width) * 0.5
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    ///
    ///  返回collectionView上面当前显示的所有元素（比如cell）的布局属性:这个方法决定了cell怎么排布
    ///  每个cell都有自己对应的布局属性：UICollectionViewLayoutAttributes
    ///  要求返回的数组中装着UICollectionViewLayoutAttributes对象
    ///
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 屏幕上显示的cell
        let array = super.layoutAttributesForElements(in: rect) ?? []
        
        // This is likely occurring because the flow layout subclass GalaryManager.LinerLayout is modifying attributes returned by UICollectionViewFlowLayout without copying them
        // http://stackoverflow.com/questions/32720358/xcode-7-copy-layoutattributes
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        for itemAttributes in array {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            // add the changes to the itemAttributesCopy
            attributesCopy.append(itemAttributesCopy)
        }
        
        // 计算 CollectionView 的中点
        let centerX = collectionView!.contentOffset.x + collectionView!.frame.size.width * 0.5
        for attrs in attributesCopy {
            // 计算 cell 中点的 x 值 与 centerX 的差值
            let delta = abs(centerX - attrs.center.x)
            // W：[0.8 ~ 1.0]
            // H：[0.3 ~ 1.0]
            // 反比
            let baseScale = 1 - delta / (collectionView!.frame.size.width + itemSize.width)
            let scaleW = minScaleW + baseScale * (1 - minScaleW)
            let scaleH = minScaleH + baseScale * (1 - minScaleH)
//            let alpha = minAlpha + baseScale * (1 - minAlpha)
            // 改变transform（越到中间 越大）
            attrs.transform = CGAffineTransform(scaleX: scaleW, y: scaleH)
//            if setAlpha {
//                // 改变透明度（越到中间 越不透明）
//                attrs.alpha = abs(alpha)
//            }
        }
        return attributesCopy
    }
    
    ///  当collectionView的bounds发生改变时，是否要刷新布局
    ///
    ///  一定要调用这个方法
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    ///  targetContentOffset ：通过修改后，collectionView最终的contentOffset(取决定情况)
    ///  proposedContentOffset ：默认情况下，collectionView最终的contentOffset
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let size = collectionView!.frame.size
        // 计算可见区域的面积
//        let rect = CGRectMake(proposedContentOffset.x, proposedContentOffset.y, size.width, size.height)
        let rect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: size.width, height: size.height)
        let array = super.layoutAttributesForElements(in: rect) ?? []
        // 计算 CollectionView 中点值
        let centerX = proposedContentOffset.x + collectionView!.frame.size.width * 0.5
        // 标记 cell 的中点与 UICollectionView 中点最小的间距
        var minDetal = CGFloat(MAXFLOAT)
        for attrs in array {
            if abs(minDetal) > abs(centerX - attrs.center.x) {
                minDetal = attrs.center.x - centerX
            }
        }
        return CGPoint(x: proposedContentOffset.x + minDetal, y: proposedContentOffset.y)
    }
    
}
