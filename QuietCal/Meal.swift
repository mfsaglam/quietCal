import Foundation

struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let grams: Int
    let kcal: Int
    let time: String
}
