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
    private let HEADER_ID = "the header IDD"
    private let INVIS_ID = "invisible cell"
    private lazy var vm: VMViewController = {return VMViewController()}()
    private var longPressGesture: UILongPressGestureRecognizer!
    private lazy var invisCell: UICollectionViewCell = {
        let cell = UICollectionViewCell()
        return cell
    }()
    private var invisCellShouldBeInstalled: Bool {
        return cv.numberOfItems(inSection: 0) == 0
    }
    
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
        return vm.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            return vm.section0Data.count + 1
        case 1:
            return vm.section1Data.count
        default:
            return 0
        }
    }
    
    //MARK: Cell Reuse
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let ID: String = indexPath.section == 0 && indexPath.item == 0
            ? INVIS_ID
            : CELL_ID
        return collectionView.dequeueReusableCell(withReuseIdentifier: ID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView
    {
        return collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HEADER_ID,
            for: indexPath
        )
    }
    
    //MARK: Data Population
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath)
    {
        if let cell = cell as? CVDraggable
        {
            switch indexPath.section
            {
            case 0:
                if 0 ..< vm.section0Data.count ~= indexPath.item - 1
                {
                    cell.populate(with: vm.section0Data[indexPath.item - 1])
                }
            case 1:
                if 0 ..< vm.section1Data.count ~= indexPath.item
                {
                    cell.populate(with: vm.section1Data[indexPath.item])
                }
            default:
                break
            }
        }
    }
    
    //MARK: Drag and Drop
    
    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
    {
//        print(cv.numberOfItems(inSection: 0)) //Possible solution
        if proposedIndexPath.section == 0 && proposedIndexPath.item == 0
        {
            return IndexPath(item: 1, section: 0)
        }
        return proposedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        canMoveItemAt indexPath: IndexPath) -> Bool
    {
        return !(indexPath.section == 0 && indexPath.item == 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath)
    {
        var item: CellObject?
        switch sourceIndexPath.section
        {
        case 0:
            item = vm.section0Data[sourceIndexPath.item - 1]
            vm.section0Data.remove(at: sourceIndexPath.item - 1)
        case 1:
            item = vm.section1Data[sourceIndexPath.item]
            vm.section1Data.remove(at: sourceIndexPath.item)
        default:
            break
        }
        if let item = item
        {
            switch destinationIndexPath.section
            {
            case 0:
                vm.section0Data.insert(item, at: destinationIndexPath.item - 1)
            case 1:
                vm.section1Data.insert(item, at: destinationIndexPath.item)
            default:
                break
            }
        }
    }
    
    //MARK: UI Behavior
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let height: CGFloat = indexPath.section == 0 && indexPath.item == 0
            ? 1
            : 38
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: 50)
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
        cv.register(UINib(nibName: String(describing: RVHeader.self), bundle: nil),
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: HEADER_ID)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: INVIS_ID)
        cv.reloadData()
    }
    
    @objc private func handleLongGesture(gesture: UILongPressGestureRecognizer)
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

