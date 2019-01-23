//
//  RVHeader.swift
//  CollectionViewReordering
//
//  Created by Xavier Lian on 1/22/19.
//  Copyright © 2019 Xavier Lian. All rights reserved.
//

import UIKit

class RVHeader: UICollectionReusableView
{
    //MARK: Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        resetUI()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        resetUI()
    }
    
    //MARK: Private Functions
    
    private func resetUI()
    {
        
    }
}
