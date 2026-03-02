# DATA_MODELS.md — Swift Data Models

## Overview

All models use `@Model` macro from SwiftData. This replaces AsyncStorage + TypeScript interfaces from the React Native app.

---

## Step.swift

```swift
import Foundation
import SwiftData

@Model
final class Step {
    var id: String
    var order: Int
    var title: String
    var stepDescription: String   // 'description' is reserved in Swift
    var imageURL: String?
    var hasTimer: Bool
    var timerDuration: Int?       // seconds; nil if hasTimer == false
    
    // Relationship (inverse of Recipe.steps)
    var recipe: Recipe?
    
    init(
        id: String = UUID().uuidString,
        order: Int,
        title: String,
        stepDescription: String,
        imageURL: String? = nil,
        hasTimer: Bool = false,
        timerDuration: Int? = nil
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.stepDescription = stepDescription
        self.imageURL = imageURL
        self.hasTimer = hasTimer
        self.timerDuration = timerDuration
    }
}
```

---

## Recipe.swift

```swift
import Foundation
import SwiftData

enum BrewMethod: String, Codable, CaseIterable {
    case standard = "standard"
    case inverted = "inverted"
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .inverted: return "Inverted"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner     = "beginner"
    case intermediate = "intermediate"
    case advanced     = "advanced"
    
    var localizedName: String {
        switch self {
        case .beginner:     return "Početnik"
        case .intermediate: return "Srednji"
        case .advanced:     return "Napredni"
        }
    }
    
    var color: String {   // Asset catalog color name
        switch self {
        case .beginner:     return "DifficultyGreen"
        case .intermediate: return "DifficultyOrange"
        case .advanced:     return "DifficultyRed"
        }
    }
}

@Model
final class Recipe {
    var id: String
    var name: String
    var author: String
    var method: BrewMethod
    var coffeeAmount: Double       // grams
    var waterAmount: Double        // ml
    var waterTemperature: Int      // °C
    var ratio: String              // e.g. "1:18"
    var totalTime: Int             // seconds
    var difficulty: Difficulty
    var isCustom: Bool
    var isFavorite: Bool = false
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step] = []
    
    init(
        id: String = UUID().uuidString,
        name: String,
        author: String,
        method: BrewMethod = .standard,
        coffeeAmount: Double,
        waterAmount: Double,
        waterTemperature: Int,
        ratio: String,
        totalTime: Int,
        difficulty: Difficulty = .beginner,
        isCustom: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.author = author
        self.method = method
        self.coffeeAmount = coffeeAmount
        self.waterAmount = waterAmount
        self.waterTemperature = waterTemperature
        self.ratio = ratio
        self.totalTime = totalTime
        self.difficulty = difficulty
        self.isCustom = isCustom
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var sortedSteps: [Step] {
        steps.sorted { $0.order < $1.order }
    }
}
```

---

## BrewSession.swift

```swift
import Foundation
import SwiftData

@Model
final class BrewSession {
    var id: String
    var recipeID: String
    var recipeName: String
    var completedAt: Date
    var rating: Int?               // 1–5, optional
    var notes: String?
    
    init(
        id: String = UUID().uuidString,
        recipeID: String,
        recipeName: String,
        completedAt: Date = .now,
        rating: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.completedAt = completedAt
        self.rating = rating
        self.notes = notes
    }
}
```

---

## TimerState (enum, not a model)

```swift
// Services/TimerService.swift

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case complete
}
```

---

## SeedData.swift — Predefined Recipes

```swift
import Foundation

// Call this on first app launch to populate SwiftData
// Check: if (try? context.fetch(FetchDescriptor<Recipe>()))?.isEmpty == true { seed() }

struct SeedData {
    
    static func allRecipes() -> [Recipe] {
        [
            jamesHoffmann(),
            invertedBasic(),
            quickMorning(),
            coldBrew()
        ]
    }
    
    // MARK: — James Hoffmann
    static func jamesHoffmann() -> Recipe {
        let recipe = Recipe(
            id: "james-hoffmann",
            name: "James Hoffmann AeroPress",
            author: "James Hoffmann",
            method: .standard,
            coffeeAmount: 11,
            waterAmount: 200,
            waterTemperature: 95,
            ratio: "1:18",
            totalTime: 150,
            difficulty: .beginner,
            isCustom: false
        )
        recipe.steps = [
            Step(id: "jh-1", order: 1,
                 title: "Priprema",
                 stepDescription: "Postavi AeroPress u standard poziciju na šalicu. Stavi papirnati filter u kapicu i isperi ga vrućom vodom.",
                 imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
                 hasTimer: false),
            Step(id: "jh-2", order: 2,
                 title: "Dodaj kavu",
                 stepDescription: "Uspi 11g svježe mljevene kave (medium-fine, poput stolne soli) u AeroPress.",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "jh-3", order: 3,
                 title: "Dodaj vodu",
                 stepDescription: "Ulij 200ml vode zagrijane na 95°C. Pokrij cijelu kavu u kružnim pokretima.",
                 imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
                 hasTimer: false),
            Step(id: "jh-4", order: 4,
                 title: "Promiješaj",
                 stepDescription: "Lagano promiješaj 3 puta kružnim pokretima kako bi sva kava bila natopljena.",
                 imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
                 hasTimer: true, timerDuration: 10),
            Step(id: "jh-5", order: 5,
                 title: "Stavi plunger",
                 stepDescription: "Stavi plunger na vrh AeroPressa da stvoriš vakuum. NE pritiskaj još!",
                 imageURL: "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800",
                 hasTimer: false),
            Step(id: "jh-6", order: 6,
                 title: "Čekaj",
                 stepDescription: "Pusti da se kava ekstrahira. Vakuum sprječava kapanje.",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 120),
            Step(id: "jh-7", order: 7,
                 title: "Swirl",
                 stepDescription: "Lagano zakreni cijeli AeroPress da se talog slegne s bočnih strana.",
                 imageURL: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800",
                 hasTimer: false),
            Step(id: "jh-8", order: 8,
                 title: "Press",
                 stepDescription: "Lagano i ravnomjerno pritiskaj plunger prema dolje. Zaustavi kad čuješ syčanje.",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 30),
            Step(id: "jh-9", order: 9,
                 title: "Gotovo!",
                 stepDescription: "Tvoja kava je spremna! Po želji razrijedi s malo vruće vode za americano stil.",
                 imageURL: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=800",
                 hasTimer: false)
        ]
        return recipe
    }
    
    // MARK: — Inverted Basic
    static func invertedBasic() -> Recipe {
        let recipe = Recipe(
            id: "inverted-basic",
            name: "Inverted Basic",
            author: "AeroPress Community",
            method: .inverted,
            coffeeAmount: 15,
            waterAmount: 220,
            waterTemperature: 92,
            ratio: "1:15",
            totalTime: 180,
            difficulty: .intermediate,
            isCustom: false
        )
        recipe.steps = [
            Step(id: "ib-1", order: 1,
                 title: "Inverted setup",
                 stepDescription: "Stavi plunger u AeroPress i okreni naopako. Plunger treba biti na razini \"1\".",
                 imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
                 hasTimer: false),
            Step(id: "ib-2", order: 2,
                 title: "Dodaj kavu",
                 stepDescription: "Uspi 15g mljevene kave (medium grind) u invertirani AeroPress.",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "ib-3", order: 3,
                 title: "Bloom",
                 stepDescription: "Dodaj 30ml vode i lagano promiješaj. Pusti da \"cvjeta\" 30 sekundi.",
                 imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
                 hasTimer: true, timerDuration: 30),
            Step(id: "ib-4", order: 4,
                 title: "Dodaj ostatak vode",
                 stepDescription: "Polako ulij preostalih 190ml vode u kružnim pokretima.",
                 imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
                 hasTimer: false),
            Step(id: "ib-5", order: 5,
                 title: "Promiješaj",
                 stepDescription: "Promiješaj 5 puta naprijed-nazad.",
                 imageURL: "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800",
                 hasTimer: true, timerDuration: 10),
            Step(id: "ib-6", order: 6,
                 title: "Steep",
                 stepDescription: "Stavi filter cap i čekaj. Ne zaboravi isprati filter prije stavljanja!",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 90),
            Step(id: "ib-7", order: 7,
                 title: "Flip & Press",
                 stepDescription: "Pažljivo okreni AeroPress na šalicu. Polako pritisni (30 sekundi).",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 30),
            Step(id: "ib-8", order: 8,
                 title: "Uživaj!",
                 stepDescription: "Tvoja kava je spremna. Inverted metoda daje fuller body okus.",
                 imageURL: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=800",
                 hasTimer: false)
        ]
        return recipe
    }
    
    // MARK: — Quick Morning
    static func quickMorning() -> Recipe {
        let recipe = Recipe(
            id: "quick-morning",
            name: "Quick Morning",
            author: "AeroPress Guide",
            method: .standard,
            coffeeAmount: 12,
            waterAmount: 180,
            waterTemperature: 90,
            ratio: "1:15",
            totalTime: 75,
            difficulty: .beginner,
            isCustom: false
        )
        recipe.steps = [
            Step(id: "qm-1", order: 1,
                 title: "Setup",
                 stepDescription: "Postavi AeroPress na šalicu. Stavi filter i isperi.",
                 imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
                 hasTimer: false),
            Step(id: "qm-2", order: 2,
                 title: "Kava i voda",
                 stepDescription: "Dodaj 12g kave, ulij 180ml vode (90°C), promiješaj jednom.",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "qm-3", order: 3,
                 title: "Čekaj",
                 stepDescription: "Stavi plunger i čekaj 45 sekundi.",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 45),
            Step(id: "qm-4", order: 4,
                 title: "Press",
                 stepDescription: "Pritisni brzo ali kontrolirano.",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 20),
            Step(id: "qm-5", order: 5,
                 title: "Gotovo!",
                 stepDescription: "Brza i ukusna kava za žurno jutro!",
                 imageURL: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=800",
                 hasTimer: false)
        ]
        return recipe
    }
    
    // MARK: — Cold Brew
    static func coldBrew() -> Recipe {
        let recipe = Recipe(
            id: "cold-brew-aeropress",
            name: "Cold Brew AeroPress",
            author: "AeroPress Guide",
            method: .standard,
            coffeeAmount: 20,
            waterAmount: 200,
            waterTemperature: 20,
            ratio: "1:10",
            totalTime: 225,
            difficulty: .beginner,
            isCustom: false
        )
        recipe.steps = [
            Step(id: "cb-1", order: 1,
                 title: "Priprema",
                 stepDescription: "Postavi AeroPress. Za cold brew koristimo više kave i hladnu vodu.",
                 imageURL: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800",
                 hasTimer: false),
            Step(id: "cb-2", order: 2,
                 title: "Dodaj kavu",
                 stepDescription: "Uspi 20g grubo mljevene kave (coarse grind, poput morske soli).",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "cb-3", order: 3,
                 title: "Dodaj hladnu vodu",
                 stepDescription: "Ulij 200ml hladne vode. Dobro promiješaj da sva kava bude natopljena.",
                 imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
                 hasTimer: false),
            Step(id: "cb-4", order: 4,
                 title: "Steep",
                 stepDescription: "Stavi plunger i ostavi 3 minute na sobnoj temperaturi. Za jači okus: do 5 minuta.",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 180),
            Step(id: "cb-5", order: 5,
                 title: "Press",
                 stepDescription: "Polako pritisni. Cold brew zahtijeva malo više snage.",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 45),
            Step(id: "cb-6", order: 6,
                 title: "Serviraj",
                 stepDescription: "Dodaj led i vodu/mlijeko po želji. Cold brew koncentrat je jak!",
                 imageURL: "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=800",
                 hasTimer: false)
        ]
        return recipe
    }
}
```

---

## SwiftData ModelContainer Setup

```swift
// AeroPressGuideApp.swift
import SwiftUI
import SwiftData

@main
struct AeroPressGuideApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Recipe.self, BrewSession.self, Step.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .onAppear {
                    seedIfNeeded()
                }
        }
    }
    
    private func seedIfNeeded() {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Recipe>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        for recipe in SeedData.allRecipes() {
            context.insert(recipe)
        }
        try? context.save()
    }
}
```
