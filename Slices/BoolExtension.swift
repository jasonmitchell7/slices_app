extension Bool {
    func toInt() -> Int? {
        switch self {
        case true:
            return 1
        case false:
            return 0
        //default:
        //    return nil
        }
    }
}
