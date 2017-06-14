let logger = Logger()

class Logger {
    var mode: loggerMode = .verbose
    
    func message(type: messageType, message: String) {
        switch (type) {
        case .error:
            print("ERROR: " + message)
        case .debug:
            if (self.mode == .debug || self.mode == .verbose) {
                print("DEBUG: " + message)
            }
        case .information:
            if (self.mode == .verbose) {
                print("INFO: " + message)
            }
        }
        print()
    }

    enum messageType {
        case error
        case debug
        case information
    }
    
    enum loggerMode {
        case normal
        case debug
        case verbose
    }
}
