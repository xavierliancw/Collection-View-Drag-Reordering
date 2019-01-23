//
//  CVDraggable.swift
//  CollectionViewReordering
//
//  Created by Xavier Lian on 1/22/19.
//  Copyright © 2019 Xavier Lian. All rights reserved.
//

import UIKit

class CVDraggable: UICollectionViewCell
{
    //MARK: Outlets
    
    @IBOutlet var topLbl: UILabel!
    @IBOutlet var botLbl: UILabel!
    @IBOutlet var gripVw: UIView!
    
    //MARK: Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
        reset()
    }
    
    //MARK: Functions
    
    func gestureIsOnGrip(_ gesture: UILongPressGestureRecognizer) -> Bool
    {
        return gripVw.frame.contains(gesture.location(in: self))
    }
    
    func populate(with data: CellObject)
    {
        topLbl.text = data.title
        botLbl.text = data.subTitle
    }
    
    //MARK: Private Functions
    
    private func reset()
    {
        topLbl.text = ""
        botLbl.text = ""
    }
}
