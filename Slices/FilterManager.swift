class FilterManager {
    static let filterList: [String: SliceFilter] = [
        "Western"   :   WesternFilter(),
        "Noir"      :   NoirFilter(),
        "Instant"   :   InstantFilter(),
        "Comic"     :   ComicFilter(),
        "Vignette"  :   VignetteFilter(),
        "Transfer"  :   TransferFilter(),
        "Process"   :   ProcessFilter(),
        "Chrome"    :   ChromeFilter(),
        "Vibrance"  :   VibranceFilter(),
        "Darken"    :   DarkenFilter(),
        "Lighten"   :   LightenFilter()
    ]
    
    static func getOrderedFilterList() -> [String] {
        var filterNames = [String]()
        
        for (key, _) in filterList {
            filterNames.append(key)
        }
        
        return filterNames.sorted(by: {$0 < $1})
    }
}
