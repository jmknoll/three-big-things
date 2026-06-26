import Foundation

extension Date {
    static var today: Date { Calendar.current.startOfDay(for: Date()) }

    var isoDateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.string(from: self)
    }

    var greetingTime: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 0..<12: return "Good morning."
        case 12..<17: return "Good afternoon."
        default: return "Good evening."
        }
    }

    var dayName: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: self)
    }

    static func from(isoDate: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.date(from: isoDate)
    }
}

extension String {
    /// Parses "HH:MM" into today's Date with those time components, or nil if invalid.
    var timeToday: Date? {
        let parts = split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = parts[0]
        comps.minute = parts[1]
        return Calendar.current.date(from: comps)
    }
}
