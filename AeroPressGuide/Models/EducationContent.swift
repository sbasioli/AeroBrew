import Foundation

struct GlossaryTerm: Identifiable, Hashable {
    let id: String
    let term: String
    let shortDescription: String
    let detailedDescription: String
}

struct Article: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let body: String
    let publishedAt: Date
    let imageURL: String
}

enum EducationContent {
    static let glossary: [GlossaryTerm] = [
        GlossaryTerm(
            id: "bloom",
            term: "Bloom",
            shortDescription: "The initial release of CO₂ when fresh coffee first meets hot water.",
            detailedDescription: """
When freshly roasted coffee first contacts hot water, it releases trapped CO₂. You'll see bubbles and a slight "swelling" of the grounds in the first 30-45 seconds.

A short bloom before the main pour helps even extraction. Typical recipe: pour 2-3x the coffee weight in water (e.g. 30g of water for 15g of coffee) and wait 30 seconds.
"""
        ),
        GlossaryTerm(
            id: "bypass",
            term: "Bypass",
            shortDescription: "Adding hot water to the cup after pressing to dilute the brew.",
            detailedDescription: """
Bypass is a technique where you brew a more concentrated base (less water through the coffee) and then add hot water to the cup to adjust the final strength and clarity.

Often used in Lance Hedrick recipes — it gives a cleaner, more vibrant cup because extraction happens through less water, pulling only the "sweetest" components.
"""
        ),
        GlossaryTerm(
            id: "extraction",
            term: "Extraction",
            shortDescription: "The process of pulling flavors from ground coffee with water.",
            detailedDescription: """
Extraction refers to the amount of dissolved coffee mass from the grounds in the final drink. It's measured as a percentage — the typical target is 18-22% for a balanced cup.

Lower extraction (under-extracted) = sour, salty, shallow. Higher (over-extracted) = bitter, dry, washed out.

You influence it via grind size (finer = more), temperature (hotter = more), contact time (longer = more), and agitation (stirring = more).
"""
        ),
        GlossaryTerm(
            id: "filter",
            term: "Filter",
            shortDescription: "Paper or metal disc that separates the coffee from the grounds.",
            detailedDescription: """
The AeroPress ships with paper filters that produce a clean, classic filter cup — they remove oils and fine particles.

Metal filters (sold separately) let through more oils and small particles, giving a cup closer to a French Press — more body but less clarity.

Paper filters can also be rinsed before use to remove any papery taste.
"""
        ),
        GlossaryTerm(
            id: "inverted",
            term: "Inverted Method",
            shortDescription: "AeroPress flipped upside-down during brewing, then turned onto the cup at press time.",
            detailedDescription: """
The inverted method means the plunger sits at the bottom and you add coffee and water from the top while the AeroPress is upside-down. Water doesn't drip through the filter prematurely, giving you complete control over steep time.

At press time, you carefully flip the AeroPress onto your cup (use both hands!) and press the plunger slowly.

Gives a fuller body and deeper extraction since the coffee has longer contact with water before pressing.
"""
        ),
        GlossaryTerm(
            id: "grind",
            term: "Grind Size",
            shortDescription: "The coarseness of ground coffee.",
            detailedDescription: """
Grind size has a major impact on extraction and flavor. AeroPress works across a wide range — from fine filter (similar to pour-over) to medium-coarse depending on the recipe.

Finer grind = more surface area = faster extraction = stronger cup. Coarser grind = slower extraction = milder cup.

Typical Comandante range: 15-35 clicks. Tim Wendelboe filter ~20 clicks, Lance Hedrick dark roast ~35 clicks.
"""
        ),
        GlossaryTerm(
            id: "plunger",
            term: "Plunger",
            shortDescription: "The piston part of the AeroPress that you press down.",
            detailedDescription: """
The plunger is the rubber-tipped piston that slides into the main chamber and presses down. It creates the pressure that pushes water through the coffee and filter into your cup.

In the inverted method, the plunger is placed first — it acts as the "bottom" of the upside-down AeroPress.

The rubber tip wears over time. AeroPress sells replacement plungers as parts.
"""
        ),
        GlossaryTerm(
            id: "press",
            term: "Press",
            shortDescription: "The final action of pushing the plunger down to brew.",
            detailedDescription: """
The press is the moment of truth. Push the plunger down slowly and evenly using your body weight. Typical press lasts 20-60 seconds.

Faster press = less extraction. Slower press = more extraction but risk of over-extracting.

The hiss at the end (air escaping) is normal — some recipes go through it, others stop just before.
"""
        ),
        GlossaryTerm(
            id: "ratio",
            term: "Ratio",
            shortDescription: "Coffee to water proportion (e.g. 1:15 means 1g coffee to 15g water).",
            detailedDescription: """
Brew ratio is the proportion of coffee mass to water mass. Common AeroPress ranges:

• 1:10 to 1:12 — concentrated, espresso-style (e.g. Wendelboe Stronger 1:9)
• 1:13 to 1:15 — balanced, classic (e.g. Hoffmann 1:18)
• 1:16 and higher — milder, cleaner, closer to filter pour-over

Less water = stronger cup. More water = weaker but easier to drink.
"""
        ),
        GlossaryTerm(
            id: "steep",
            term: "Steep",
            shortDescription: "The contact time between water and coffee before pressing.",
            detailedDescription: """
Steep time is the period when coffee slowly releases flavors into water before you press the plunger. Typically 30 seconds to 4 minutes, depending on the recipe.

Shorter steep = brighter, more acidic, less extraction. Longer steep = fuller, sweeter, more body but a risk of bitterness.

Steep matters most in the inverted method since water doesn't drip out of the filter prematurely.
"""
        ),
        GlossaryTerm(
            id: "tds",
            term: "TDS",
            shortDescription: "Total Dissolved Solids — the strength of your brew.",
            detailedDescription: """
TDS (Total Dissolved Solids) measures how much coffee is dissolved in the final cup, as a percentage. AeroPress typically gives 1.2% – 1.6% TDS — between filter pour-over (1.3%) and espresso (8-12%).

TDS is measured with a refractometer. Combined with extraction yield (%) it tells you how evenly and completely your coffee was extracted.

Higher TDS = stronger, more concentrated cup.
"""
        ),
        GlossaryTerm(
            id: "temperature",
            term: "Water Temperature",
            shortDescription: "The heat of brewing water — affects extraction speed.",
            detailedDescription: """
The SCA standard recommends 90-96°C for most methods. AeroPress accepts a wider range — from 80°C (Lance Hedrick dark roast) to 100°C (Wendelboe Stronger).

Lower temperature = slower extraction = better for dark roasts (less bitterness). Higher temperature = faster extraction = better for light roasts (releases more sweetness and acidity).
"""
        )
    ]

    static let articles: [Article] = [
        Article(
            id: "filter-types",
            title: "Paper or Metal Filter?",
            summary: "How to pick the filter that suits your style and your beans.",
            body: """
Paper filters are the default AeroPress accessory — they produce a clean, transparent cup. They trap oils and fine particles, leaving a clear, lighter drink similar to pour-over.

Metal filters (Disk, Fellow Prismo, Able) let through more oils and microparticles. The cup is fuller and "thicker" but less clean — some love it, others don't.

Practical tip: if you love filter coffee (V60, Kalita) — stick with paper. If you love French Press or espresso — try metal.

Rinse paper filters with hot water before use to remove any papery taste and pre-warm the brewer. They can also be reused 2-3 times if they're in good shape.
""",
            publishedAt: Date(timeIntervalSince1970: 1731628800),
            imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800"
        ),
        Article(
            id: "inverted-vs-standard",
            title: "Inverted vs Standard — Which Method For You?",
            summary: "The differences between the two most common AeroPress positions.",
            body: """
Standard position: the AeroPress sits on top of your cup and water can slowly drip through the filter as you brew. Faster, simpler, less spillage risk. Ideal for beginners and daily routines.

Inverted position: the AeroPress is upside-down, the plunger holds water in until you flip. You get full control over steep time — coffee won't drip until you decide. Requires some skill on the flip (use both hands!).

Standard works best for: quick mornings, classic filter recipes (Hoffmann, Wendelboe), when you want a clean cup.

Inverted works best for: longer steep times, full immersion brewing, experimenting with extraction, dark roasts (Lance Hedrick recipes).

Try both with the same coffee and same parameters — the difference in body and texture is noticeable.
""",
            publishedAt: Date(timeIntervalSince1970: 1733616000),
            imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800"
        ),
        Article(
            id: "common-mistakes",
            title: "Common AeroPress Mistakes and How to Fix Them",
            summary: "Small details that turn a good cup into a great one.",
            body: """
1. Not rinsing the paper filter
You'll get a slight papery taste. Always rinse the filter with hot water for 5-10 seconds before adding coffee.

2. Tap water
Water quality is 99% of coffee quality. Use filtered or spring water with 60-150 ppm TDS.

3. Old coffee
Beans are at their best 7-30 days post-roast. Older than 60 days — flat and lifeless.

4. Steep too long or too short
Follow the recipe. If it's bitter — shorten the steep or cool the water. If it's sour and thin — extend the steep or warm the water.

5. Press too fast or too slow
The target is 20-30 seconds for standard, 30-60 for inverted. If you hear hissing early — the bed is overpacked (too much coffee or too fine a grind).

6. Wrong grind
Too fine = bitter + slow drain. Too coarse = sour + thin. Calibrate your grinder.

7. Not weighing the coffee
Without a scale every cup is different. Invest in a digital scale (a kitchen scale works, just make sure it has 0.1g precision for coffee and 1g for water).
""",
            publishedAt: Date(timeIntervalSince1970: 1735603200),
            imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800"
        ),
        Article(
            id: "extraction-science",
            title: "The Science of Extraction — What Happens In an AeroPress",
            summary: "Understanding extraction makes you a better brewer.",
            body: """
Coffee contains around 2,000 different compounds, but only ~30% of the total mass can dissolve in water. The goal of brewing is to dissolve the optimal amount from that soluble mass.

Extraction phases over time:
1. First seconds — acids (bright, fruity, citrusy)
2. 30-90s — sweetness (caramel, chocolate, fruit)
3. 90s+ — bitterness (nutty, dry, unpleasant)

The goal is to stop extraction when you've balanced acidity and sweetness, before the bitterness arrives. That's around 18-22% extraction.

Variables you control:
• GRIND (biggest impact) — finer = more surface area = faster extraction
• TEMPERATURE — higher = faster extraction
• TIME — longer = more
• AGITATION — stirring increases extraction
• RATIO — more water extracts more but dilutes

The AeroPress is uniquely flexible because you can change all of these variables. A gentle press gives you a full immersion brew like a French Press, while an aggressive press pushes you closer to espresso.
""",
            publishedAt: Date(timeIntervalSince1970: 1737590400),
            imageURL: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800"
        )
    ]
}
