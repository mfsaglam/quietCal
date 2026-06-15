import Foundation

extension Array where Element == Meal {
    var csvString: String {
        let header = "date,time,name,grams,kcal"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        let rows = self.map { meal in
            let date = dateFormatter.string(from: meal.createdAt)
            let time = timeFormatter.string(from: meal.createdAt)
            let escapedName = csvEscape(meal.name)
            return "\(date),\(time),\(escapedName),\(meal.grams),\(meal.kcal)"
        }
        return ([header] + rows).joined(separator: "\n")
    }
}

private func csvEscape(_ field: String) -> String {
    let needsQuoting = field.contains(",") || field.contains("\"") || field.contains("\n")
    let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
    return needsQuoting ? "\"\(escaped)\"" : escaped
}
