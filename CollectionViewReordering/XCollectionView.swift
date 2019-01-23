//
//  XCollectionView.swift
//  Sypher
//
//  Created by Xavier Lian on 9/6/18.
//  Copyright © 2018 AstroMedia. All rights reserved.
//

import UIKit

class XCollectionView: UICollectionView
{
    //MARK: Properties
    
    var flowLayout: UICollectionViewFlowLayout? {
        get {return collectionViewLayout as? UICollectionViewFlowLayout}
    }
    
    //MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool
    {
        //Allow scrolling even when finger lands on top of a button
        if view.isKind(of: UIButton.self)
        {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    //MARK: Private Functions
    
    private func setup()
    {
        delaysContentTouches = false
    }
}
