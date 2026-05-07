import SwiftUI

struct ParameterGridView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 0) {
            ParameterCell(icon: "cup.and.saucer.fill",
                          value: "\(Int(recipe.coffeeAmount))g",
                          label: "Coffee")
            ParameterCell(icon: "drop.fill",
                          value: "\(Int(recipe.waterAmount))ml",
                          label: "Water")
            ParameterCell(icon: "thermometer",
                          value: "\(recipe.waterTemperature)°C",
                          label: "Temp.")
            ParameterCell(icon: "scalemass",
                          value: recipe.ratio,
                          label: "Ratio")
        }
        .padding(16)
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("BrandPrimary").opacity(0.06), radius: 8, y: 2)
    }
}

struct ParameterCell: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color("BrandAccent"))
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
