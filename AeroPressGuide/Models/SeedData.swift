import Foundation

struct SeedData {

    static func allRecipes() -> [Recipe] {
        [
            jamesHoffmann(),
            invertedBasic(),
            quickMorning(),
            coldBrew()
        ]
    }

    // MARK: - James Hoffmann
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
                 title: "Preparation",
                 stepDescription: "Set up AeroPress in standard position on your cup. Place a paper filter in the cap and rinse with hot water.",
                 imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
                 hasTimer: false),
            Step(id: "jh-2", order: 2,
                 title: "Add Coffee",
                 stepDescription: "Add 11g of freshly ground coffee (medium-fine, like table salt) into the AeroPress.",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "jh-3", order: 3,
                 title: "Add Water",
                 stepDescription: "Pour 200ml of water heated to 95°C. Cover all the coffee in circular motions.",
                 imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
                 hasTimer: false),
            Step(id: "jh-4", order: 4,
                 title: "Stir",
                 stepDescription: "Gently stir 3 times in circular motions so all coffee is saturated.",
                 imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
                 hasTimer: true, timerDuration: 10),
            Step(id: "jh-5", order: 5,
                 title: "Insert Plunger",
                 stepDescription: "Place the plunger on top of the AeroPress to create a vacuum. DON'T press yet!",
                 imageURL: "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800",
                 hasTimer: false),
            Step(id: "jh-6", order: 6,
                 title: "Wait",
                 stepDescription: "Let the coffee extract. The vacuum prevents dripping.",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 120),
            Step(id: "jh-7", order: 7,
                 title: "Swirl",
                 stepDescription: "Gently swirl the entire AeroPress so the sediment settles from the sides.",
                 imageURL: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800",
                 hasTimer: false),
            Step(id: "jh-8", order: 8,
                 title: "Press",
                 stepDescription: "Slowly and evenly push the plunger down. Stop when you hear hissing.",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 30),
            Step(id: "jh-9", order: 9,
                 title: "Done!",
                 stepDescription: "Your coffee is ready! Optionally dilute with a little hot water for an americano style.",
                 imageURL: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=800",
                 hasTimer: false)
        ]
        return recipe
    }

    // MARK: - Inverted Basic
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
                 stepDescription: "Place the plunger in the AeroPress and flip upside down. The plunger should be at level \"1\".",
                 imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
                 hasTimer: false),
            Step(id: "ib-2", order: 2,
                 title: "Add Coffee",
                 stepDescription: "Add 15g of ground coffee (medium grind) into the inverted AeroPress.",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "ib-3", order: 3,
                 title: "Bloom",
                 stepDescription: "Add 30ml of water and gently stir. Let it \"bloom\" for 30 seconds.",
                 imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
                 hasTimer: true, timerDuration: 30),
            Step(id: "ib-4", order: 4,
                 title: "Add Remaining Water",
                 stepDescription: "Slowly pour the remaining 190ml of water in circular motions.",
                 imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
                 hasTimer: false),
            Step(id: "ib-5", order: 5,
                 title: "Stir",
                 stepDescription: "Stir 5 times back and forth.",
                 imageURL: "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800",
                 hasTimer: true, timerDuration: 10),
            Step(id: "ib-6", order: 6,
                 title: "Steep",
                 stepDescription: "Place the filter cap and wait. Don't forget to rinse the filter before attaching!",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 90),
            Step(id: "ib-7", order: 7,
                 title: "Flip & Press",
                 stepDescription: "Carefully flip the AeroPress onto your cup. Press slowly (30 seconds).",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 30),
            Step(id: "ib-8", order: 8,
                 title: "Enjoy!",
                 stepDescription: "Your coffee is ready. The inverted method gives a fuller body flavor.",
                 imageURL: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=800",
                 hasTimer: false)
        ]
        return recipe
    }

    // MARK: - Quick Morning
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
                 stepDescription: "Set up AeroPress on your cup. Place the filter and rinse.",
                 imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
                 hasTimer: false),
            Step(id: "qm-2", order: 2,
                 title: "Coffee & Water",
                 stepDescription: "Add 12g of coffee, pour 180ml of water (90°C), stir once.",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "qm-3", order: 3,
                 title: "Wait",
                 stepDescription: "Place the plunger and wait 45 seconds.",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 45),
            Step(id: "qm-4", order: 4,
                 title: "Press",
                 stepDescription: "Press quickly but controlled.",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 20),
            Step(id: "qm-5", order: 5,
                 title: "Done!",
                 stepDescription: "Fast and delicious coffee for a busy morning!",
                 imageURL: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=800",
                 hasTimer: false)
        ]
        return recipe
    }

    // MARK: - Cold Brew
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
                 title: "Preparation",
                 stepDescription: "Set up AeroPress. For cold brew we use more coffee and cold water.",
                 imageURL: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800",
                 hasTimer: false),
            Step(id: "cb-2", order: 2,
                 title: "Add Coffee",
                 stepDescription: "Add 20g of coarsely ground coffee (coarse grind, like sea salt).",
                 imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
                 hasTimer: false),
            Step(id: "cb-3", order: 3,
                 title: "Add Cold Water",
                 stepDescription: "Pour 200ml of cold water. Stir well so all coffee is saturated.",
                 imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
                 hasTimer: false),
            Step(id: "cb-4", order: 4,
                 title: "Steep",
                 stepDescription: "Place the plunger and leave for 3 minutes at room temperature. For a stronger taste: up to 5 minutes.",
                 imageURL: "https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=800",
                 hasTimer: true, timerDuration: 180),
            Step(id: "cb-5", order: 5,
                 title: "Press",
                 stepDescription: "Press slowly. Cold brew requires a bit more force.",
                 imageURL: "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=800",
                 hasTimer: true, timerDuration: 45),
            Step(id: "cb-6", order: 6,
                 title: "Serve",
                 stepDescription: "Add ice and water/milk as desired. Cold brew concentrate is strong!",
                 imageURL: "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=800",
                 hasTimer: false)
        ]
        return recipe
    }
}
