//
//  ViewController.swift
//  CollectionViewReordering
//
//  Created by Xavier Lian on 1/22/19.
//  Copyright © 2019 Xavier Lian. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    //MARK: Private Properties
    
    private let CELL_ID = "this is the ID for the cells lol"
    private lazy var vm: VMViewController = {return VMViewController()}()
    private var longPressGesture: UILongPressGestureRecognizer!
    
    //MARK: Outlets
    
    @IBOutlet private var cv: XCollectionView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCV()
    }
}

//MARK:- Collection View Delegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    //MARK: Data Quantity
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return vm.data.count
    }
    
    //MARK: Cell Reuse
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath)
    }
    
    //MARK: Data Population
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath)
    {
        if let cell = cell as? CVDraggable,
            0 ..< vm.data.count ~= indexPath.item
        {
            cell.populate(with: vm.data[indexPath.item])
        }
    }
    
    //MARK: Drag and Drop
    
    func collectionView(_ collectionView: UICollectionView,
                        canMoveItemAt indexPath: IndexPath) -> Bool
    {
        if indexPath.section == 0
        {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath)
    {
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }
    
    //MARK: UI Behavior
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: 38)
    }
    
    private func setupCV()
    {
        longPressGesture = UILongPressGestureRecognizer(
            target: self, action: #selector(handleLongGesture(gesture:))
        )
        cv.addGestureRecognizer(longPressGesture)
        cv.delegate = self
        cv.dataSource = self
        cv.flowLayout?.minimumLineSpacing = 1
        cv.register(UINib(nibName: String(describing: CVDraggable.self), bundle: nil),
                    forCellWithReuseIdentifier: CELL_ID)
        cv.reloadData()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        switch(gesture.state)
        {
        case .began:
            guard let selectedIndexPath = cv.indexPathForItem(at: gesture.location(in: cv)) else {
                break
            }
            if let cell = cv.cellForItem(at: selectedIndexPath) as? CVDraggable,
                cell.gestureIsOnGrip(gesture)
            {
                cv.beginInteractiveMovementForItem(at: selectedIndexPath)
            }
        case .changed:
            if let gestVw = gesture.view
            {
                //Prevent lateral movement during dragging
                cv.updateInteractiveMovementTargetPosition(
                    CGPoint(x: cv.center.x, y: gesture.location(in: gestVw).y)
                )
            }
            else
            {
                cv.cancelInteractiveMovement()
            }
        case .ended:
            cv.endInteractiveMovement()
        default:
            cv.cancelInteractiveMovement()
        }
    }
}

