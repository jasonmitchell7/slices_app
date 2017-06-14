extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.year]), from: date, to: self).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.month]), from: date, to: self).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.weekOfYear]), from: date, to: self).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.day]), from: date, to: self).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.hour]), from: date, to: self).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.minute]), from: date, to: self).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return Calendar.current.dateComponents(Set([.second]), from: date, to: self).second!
    }
    func timeFrom(date: Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))yr"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))mo"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))wk"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

func stringToDateShort(_ dateStr: String!) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let dateFromString: Date! = dateFormatter.date(from: dateStr)
    
    return dateFromString
}

func stringToDateLong(_ dateStr: String!) -> Date {
    // Check if the API token has expired.
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    let dateFromString: Date! = dateFormatter.date(from: dateStr)
    
    return dateFromString
}
