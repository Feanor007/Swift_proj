//
//  DocumentViewController.swift
//  TrailingTest
//
//  Created by 唐泽宇 on 2019/3/28.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import UIKit
extension NumberCardsSet.CardInfo{
    init?(label: UILabel){
        if let attributedText = label.attributedText, let font = attributedText.font{
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attributedText.string
            size = Int(font.pointSize)
        }
        else{
            return nil
        }
    }
}
extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
class DocumentViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    var numbersChoices = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"]
    var numberOfCorrectMatches = 0
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(60.0))
    }
    private var numberCardsSet: NumberCardsSet?{
        get{
            let cards = TestDraw.subviews.compactMap{$0 as? UILabel}.compactMap{NumberCardsSet.CardInfo(label: $0)} 
            return NumberCardsSet(numberCards: cards)
        }
        set{
            TestDraw.subviews.compactMap{$0 as? UILabel}.forEach{$0.removeFromSuperview()}
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbersChoices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "numberCell", for: indexPath)
        if let numberCell = cell as? numberCollectionViewCell{
            let text = NSAttributedString(string: numbersChoices[indexPath.item], attributes: [.font:font])
            numberCell.label.attributedText = text
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move: .copy, intent: .insertAtDestinationIndexPath)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath{
                if let attributedString = item.dragItem.localObject as? NSAttributedString{
                    collectionView.performBatchUpdates({numbersChoices.remove(at: sourceIndexPath.item)
                        numbersChoices.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])})
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }else{
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self){(provider, error) in DispatchQueue.main.sync {
                    if let attributedString = provider as? NSAttributedString{
                        placeholderContext.commitInsertion(dataSourceUpdates: {insertionIndexPath in
                            self.numbersChoices.insert(attributedString.string, at: insertionIndexPath.item)
                        })
                    }else {
                        placeholderContext.deletePlaceholder()
                    }
                    }
                }
            }
        }
    }
    private func dragItems (at indexPath: IndexPath) -> [UIDragItem]{
        if let attributedString = (numberCollectionView.cellForItem(at: indexPath) as? numberCollectionViewCell)?.label.attributedText{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        }else {
            return []
        }
    }
    private func check(){
        for item in TestDraw.UILabelLocation.indices {
            if TestDraw.UILabelLocation[item] - TestDraw.UserMatchingLocation[item] < 25 {
                numberOfCorrectMatches += 1
            }
        }
        print("You've got \(numberOfCorrectMatches) correct")
    }
    @IBOutlet weak var numberCollectionView: UICollectionView!{
        didSet{
            numberCollectionView.dataSource = self
            numberCollectionView.delegate = self
            numberCollectionView.dragDelegate = self
            numberCollectionView.dropDelegate = self
        }
    }
    
    @IBOutlet weak var TestDraw: TrailingCanvas!
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        if TestDraw.path != nil{    
            TestDraw.ClearCanvas()
        }
         //print("This is user's trail making:\(TestDraw.UserMatchingLocation)")
         //print("This is where user drops the label:\(TestDraw.UILabelLocation)")
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true){
            self.document?.close()
        }
        if document?.numberCardsSet != nil{
            document?.thumbnail = TestDraw.snapshot
            print("thumbnail added")
            
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        check()
        document?.numberCardsSet = numberCardsSet
        if document?.numberCardsSet != nil {
            document?.updateChangeCount(.done)
        }
        createCSVX(from: patientsData)
        let message = "The number of correct match is:\(numberOfCorrectMatches)"
        let alert = UIAlertController(title: "Hola", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Donot give up", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
var patientsData:[Dictionary<String, AnyObject>] = Array()
var dct = Dictionary<String, AnyObject>()

// MARK: CSV writing
func createCSVX(from recArray:[Dictionary<String, AnyObject>]) {
    var csvString = "\("Time")\n"
    dct.updateValue(TestDraw.time as AnyObject, forKey: "T")
    csvString = csvString.appending("\(String(describing: dct["T"]))\n")
    patientsData.append(dct)
    let fileManager = FileManager.default
    do {
        let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
        let fileURL = path.appendingPathComponent("TrailTime.csv")
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
        print("error creating file")
    }
    
}
var document: NumberCardsSetDocument?
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    document?.open {
        success in
        if success{
            self.title = self.document?.localizedName
            self.numberCardsSet = self.document?.numberCardsSet
        }
    }
}
}
