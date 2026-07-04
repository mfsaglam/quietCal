import Testing
@testable import QuietCal

struct MealPhraseParserTests {
    @Test func parsesGramsAndFoodName() {
        let result = MealPhraseParser.parse("200 grams of grilled chicken")
        #expect(result.grams == 200)
        #expect(result.foodName == "grilled chicken")
    }

    @Test func normalisesOuncesToGrams() {
        let result = MealPhraseParser.parse("8 oz salmon")
        #expect(result.grams == 227) // 8 * 28.3495 rounded
        #expect(result.foodName == "salmon")
    }

    @Test func treatsMillilitresAsGrams() {
        let result = MealPhraseParser.parse("250 ml orange juice")
        #expect(result.grams == 250)
        #expect(result.foodName == "orange juice")
    }

    @Test func fallsBackToDefaultGramsWhenNoAmount() {
        let result = MealPhraseParser.parse("banana")
        #expect(result.grams == MealPhraseParser.defaultGrams)
        #expect(result.foodName == "banana")
    }

    @Test func parsesDecimalAndPoundUnit() {
        let result = MealPhraseParser.parse("1.5 lb ground beef")
        #expect(result.grams == 680) // 1.5 * 453.592 rounded
        #expect(result.foodName == "ground beef")
    }

    @Test func keepsOriginalPhraseWhenNoFoodTokensRemain() {
        let result = MealPhraseParser.parse("100 g")
        #expect(result.grams == 100)
        #expect(result.foodName == "100 g")
    }
}
