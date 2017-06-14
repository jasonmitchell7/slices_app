import UIKit

class ToppingsCollectionView: NibLoadingView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public weak var navController: UINavigationController?
    
    public var slice: Slice? {
        didSet {
            loadToppings()
        }
    }
    
    private let identifier = "ToppingsCell"
    
    private func loadToppings() {
        if (collectionView.delegate == nil) {
            setupCollectionView()
        }
        
        if (slice != nil) {
            slice?.requestToppings({(success) -> Void in
                if (success) {
                    self.collectionView.reloadData()
                    logger.message(type: .information, message: "Loaded Toppings into Toppings Collection View successfully.")
                } else {
                    logger.message(type: .error, message: "Could not load toppings for Slice: \(self.slice?.sliceID) in Toppings Collection View.")
                }
            })
        } else {
            logger.message(type: .debug, message: "Attempted to load Toppings in Toppings Collection View, but Slice was nil.")
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ToppingsCellView", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (slice == nil) ? 0 : slice!.toppings.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ToppingsCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ToppingsCell
        
        if (slice != nil) {
            cell.navController = navController
            cell.slice = slice!.toppings[indexPath.item]
        } else {
            logger.message(type: .debug, message: "Attempted to create cell (\(indexPath.item)) in Toppings Collection View, but Slice was nil.")
        }
        
        return cell
    }
    
}
