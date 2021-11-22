//
//  PinterestLayout.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation
import UIKit

protocol PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    var delegate: PinterestLayoutDelegate?
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    var numberOfColumns = 2
    private let cellPadding: CGFloat = 6

    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let inset = collectionView.contentInset
        let horizontalInsets = inset.left + inset.right
        
        return collectionView.bounds.width - horizontalInsets
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    // Calculating all the layout
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        
        var xOffSets: [CGFloat] = []
        var yOffSets: [CGFloat] = .init(repeating: 0.0, count: numberOfColumns)
        
        for column in 0..<numberOfColumns {
            let xOffSet: CGFloat = (columnWidth * CGFloat(column))
            xOffSets.append(xOffSet)
        }
        
        var indexPaths: [IndexPath] = []
        for index in 0..<collectionView.numberOfItems(inSection: 0) {
            let newIndex = IndexPath(item: index, section: 0)
            indexPaths.append(newIndex)
        }
        
        var column = 0
        for indexPath in indexPaths {
            //Width to use for height calculation at ViewController
            let horizontalPaddings = cellPadding * 2
            let frameWidth = columnWidth - horizontalPaddings

            //Normal calculation
            let photoHeight = delegate?.collectionView(collectionView: collectionView, heightForItemAtIndexPath: indexPath, width: frameWidth) ?? 180
            
            let verticalPaddings = cellPadding * 2
            let height = photoHeight + verticalPaddings
            
            let frame = CGRect(x: xOffSets[column], y: yOffSets[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(frame.maxY, contentHeight)
            yOffSets[column] += height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    // Passing the cache
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//
//        return cache[indexPath.item]
//    }
}
