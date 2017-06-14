import UIKit

protocol CameraFiltersViewDelegate {
    func didChangeAppliedFilters(filterList: [String])
}

class CameraFiltersView: NibLoadingView {
    let filterViewPadding: Int = 2
    let filterViewTopInset: Int = 20
    
    var delegate: CameraFiltersViewDelegate?
    
    var sliceMedia: SliceMedia? {
        didSet {
            layoutFilters()
        }
    }
    
    @IBOutlet weak var availableFiltersScrollView: UIScrollView!
    @IBOutlet weak var appliedFiltersScrollView: UIScrollView!
    
    func layoutFilters() {
        if (sliceMedia?.image != nil) {
            layoutAvailableFilters(image: sliceMedia!.image!)
            layoutAppliedFilters(image: sliceMedia!.image!)
        }
    }
    
    private func removeAllSubviewsFromAvailableFilters() {
        let subviews = availableFiltersScrollView.subviews
        
        for subview in subviews {
            if (subview.tag == SliceTimelineBlock.size) {
                subview.removeFromSuperview()
            }
        }
        
        availableFiltersScrollView.contentSize = self.frame.size
        availableFiltersScrollView.contentOffset = CGPoint.zero
    }
    
    private func layoutAvailableFilters(image: UIImage) {
        removeAllSubviewsFromAvailableFilters()
        
        var index: Int = 0
        
        for filterName in FilterManager.getOrderedFilterList() {
            addAvailableFilterToScrollView(
                index: index,
                filterName: filterName,
                image: image.getFilteredImage(filterList: [filterName])
            )
            
            index += 1
        }
        
        availableFiltersScrollView.contentSize = CGSize(
            width: CGFloat(getPositionForFilterView(index: index) + (2 * filterViewPadding)),
            height: availableFiltersScrollView.frame.height
        )
        
        availableFiltersScrollView.isScrollEnabled = availableFiltersScrollView.contentSize.width > availableFiltersScrollView.frame.width
        availableFiltersScrollView.isUserInteractionEnabled = true
    }
    
    private func addAvailableFilterToScrollView(index: Int, filterName: String, image: UIImage) {
        let position = getPositionForFilterView(index: index)
        let button: UIButton = UIButton(type: .custom)
        
        button.tag = SliceTimelineBlock.size
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = CGFloat(getFilterViewSize() / 2)
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        button.setTitle(filterName, for: .normal)
        
        button.addTarget(self, action: #selector(didPressAvailableFilter(_:)), for: .touchUpInside)
        
        availableFiltersScrollView.addSubview(button)
        
        button.frame = CGRect(
            x: position,
            y: filterViewPadding,
            width: getFilterViewSize(),
            height: getFilterViewSize()
        )
        
        let label = UILabel()
        label.tag = SliceTimelineBlock.size
        label.text = filterName
        label.font = UIFont(name: "AvenirNextCondensed-Regular", size: 11)
        label.textColor = styleMgr.colorPrimary
        label.textAlignment = .center
        
        availableFiltersScrollView.addSubview(label)
        
        label.frame = CGRect(
            x: position,
            y: filterViewPadding + getFilterViewSize(),
            width: getFilterViewSize(),
            height: filterViewTopInset
        )
    }
    
    private func removeAllSubviewsFromAppliedFilters() {
        let subviews = appliedFiltersScrollView.subviews
        
        for subview in subviews {
            if (subview.tag == SliceTimelineBlock.size) {
                subview.removeFromSuperview()
            }
        }
        
        appliedFiltersScrollView.contentSize = self.frame.size
        appliedFiltersScrollView.contentOffset = CGPoint.zero
    }
    
    private func layoutAppliedFilters(image: UIImage) {
        removeAllSubviewsFromAppliedFilters()
        
        if (sliceMedia == nil) {
            return
        }
        
        var index: Int = 0
        
        var lastFilteredImage: UIImage = image
        
        for filterName in sliceMedia!.filters {
            lastFilteredImage = lastFilteredImage.getFilteredImage(filterList: [filterName])
            addAppliedFilterToScrollView(
                index: index,
                filterName: filterName,
                image: lastFilteredImage
            )
            
            index += 1
        }
        
        appliedFiltersScrollView.contentSize = CGSize(
            width: CGFloat(getPositionForFilterView(index: index) + (2 * filterViewPadding)),
            height: appliedFiltersScrollView.frame.height
        )
        
        appliedFiltersScrollView.isScrollEnabled = appliedFiltersScrollView.contentSize.width > appliedFiltersScrollView.frame.width
        appliedFiltersScrollView.isUserInteractionEnabled = true
    }
    
    private func addAppliedFilterToScrollView(index: Int, filterName: String, image: UIImage) {
        let position = getPositionForFilterView(index: index)
        let button: UIButton = UIButton(type: .custom)
        
        button.tag = SliceTimelineBlock.size
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = CGFloat(getFilterViewSize() / 2)
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        button.setTitle("\(index)", for: .normal)
        
        button.addTarget(self, action: #selector(didPressAppliedFilter(_:)), for: .touchUpInside)
        
        appliedFiltersScrollView.addSubview(button)
        
        button.frame = CGRect(
            x: position,
            y: filterViewPadding,
            width: getFilterViewSize(),
            height: getFilterViewSize()
        )
        
        let label = UILabel()
        label.tag = SliceTimelineBlock.size
        label.text = filterName
        label.font = UIFont(name: "AvenirNextCondensed-Regular", size: 11)
        label.textColor = styleMgr.colorPrimary
        label.textAlignment = .center
        
        appliedFiltersScrollView.addSubview(label)
        
        label.frame = CGRect(
            x: position,
            y: filterViewPadding + getFilterViewSize(),
            width: getFilterViewSize(),
            height: filterViewTopInset
        )
    }
    
    private func getPositionForFilterView(index: Int) -> Int {
        return (index * getFilterViewSize()) + (index * filterViewPadding)
    }
    
    private func getFilterViewSize() -> Int {
        return (
            Int(floor(availableFiltersScrollView.frame.height)) -
            (2 * filterViewPadding) -
            filterViewTopInset
        )
    }
    
    func didPressAvailableFilter(_ button: UIButton) {
        if (sliceMedia != nil) {
            if let filterName = button.title(for: .normal) {
                sliceMedia!.filters.append(filterName)
                delegate?.didChangeAppliedFilters(filterList: sliceMedia!.filters)
                layoutFilters()
            } else {
                logger.message(type: .error, message: "Could not get filter name from available filter button.")
            }
        } else {
            logger.message(type: .error, message: "Attempted to apply filter with nil media.")
        }
    }
    
    func didPressAppliedFilter(_ button: UIButton) {
        if (sliceMedia != nil) {
            if let title = button.title(for: .normal) {
                if let index = Int(title) {
                    if (index >= 0 && index < sliceMedia!.filters.count) {
                        sliceMedia!.filters.remove(at: index)
                        delegate?.didChangeAppliedFilters(filterList: sliceMedia!.filters)
                        layoutFilters()
                    } else {
                        logger.message(type: .error, message: "Attempted to remove filter with out of bounds index: \(index).")
                    }
                } else {
                    logger.message(type: .error, message: "Could not get index from applied filter.")
                }
            } else {
                logger.message(type: .error, message: "Could not get index string from applied filter.")
            }
        } else {
            logger.message(type: .error, message: "Attempted to apply filter with nil media.")
        }
    }
}
