import SwiftUI
import SwiftData

struct RecipeEditView: View {
    enum Mode: Equatable {
        case createNew
        case editExisting(Recipe)
    }

    let mode: Mode
    let templates: [Recipe]
    let onSave: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]

    @State private var draft: RecipeDraft
    @State private var showTemplatePicker: Bool = false

    init(
        mode: Mode,
        initialDraft: RecipeDraft = RecipeDraft(),
        templates: [Recipe] = [],
        onSave: @escaping (Recipe) -> Void
    ) {
        self.mode = mode
        self.templates = templates
        self.onSave = onSave
        _draft = State(initialValue: initialDraft)
    }

    private var titleText: String {
        switch mode {
        case .createNew: return "New Recipe"
        case .editExisting: return "Edit Recipe"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if mode == .createNew && !templates.isEmpty {
                    Section {
                        Button {
                            showTemplatePicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Image(systemName: "doc.on.doc")
                                    Text("Use Existing as Template")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.brandTextSecondary)
                                }
                                Text("Pre-fills all fields and steps from an existing recipe — change anything you like.")
                                    .font(.caption)
                                    .foregroundStyle(Color.brandTextSecondary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Recipe") {
                    TextField("Name", text: $draft.name)
                    TextField("Author", text: $draft.author)
                    Picker("Method", selection: $draft.method) {
                        ForEach(BrewMethod.allCases, id: \.self) { method in
                            Text(method.displayName).tag(method)
                        }
                    }
                    Picker("Difficulty", selection: $draft.difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.localizedName).tag(difficulty)
                        }
                    }
                }

                Section("Parameters") {
                    Stepper(value: $draft.coffeeAmount, in: 5...60, step: 1) {
                        HStack {
                            Text("Coffee")
                            Spacer()
                            Text("\(Int(draft.coffeeAmount)) g")
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                    }
                    Stepper(value: $draft.waterAmount, in: 50...500, step: 10) {
                        HStack {
                            Text("Water")
                            Spacer()
                            Text("\(Int(draft.waterAmount)) ml")
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                    }
                    Stepper(value: $draft.waterTemperature, in: 70...100) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text("\(draft.waterTemperature) °C")
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                    }
                    HStack {
                        Text("Ratio")
                        Spacer()
                        Text(draft.ratio)
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                }

                ForEach($draft.steps) { $step in
                    let stepIndex = indexOf(step)
                    Section {
                        TextField("Title", text: $step.title)
                            .font(.body.weight(.medium))
                            .padding(.vertical, 4)

                        TextField("Description", text: $step.detail, axis: .vertical)
                            .lineLimit(2...5)
                            .foregroundStyle(Color.brandTextSecondary)
                            .padding(.vertical, 4)

                        Toggle("Timer", isOn: $step.hasTimer)
                            .padding(.vertical, 4)

                        if step.hasTimer {
                            Stepper(value: $step.timerDuration, in: 5...600, step: 5) {
                                HStack {
                                    Text("Duration")
                                    Spacer()
                                    Text(formatted(seconds: step.timerDuration))
                                        .foregroundStyle(Color.brandTextSecondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        HStack {
                            Text("Step \(stepIndex + 1)")
                            Spacer()
                            if draft.steps.count > 1 {
                                Button(role: .destructive) {
                                    if let id = draft.steps[safe: stepIndex]?.id {
                                        draft.steps.removeAll { $0.id == id }
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color(hex: 0xA32D2D))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        draft.steps.append(StepDraft())
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Step")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(!draft.isValid)
                }
            }
            .onAppear {
                if mode == .createNew && draft.author.trimmingCharacters(in: .whitespaces).isEmpty {
                    draft.author = "Custom"
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                RecipeTemplatePicker(recipes: templates) { recipe in
                    var newDraft = RecipeDraft.from(recipe, copyForCustom: true)
                    newDraft.author = "Custom"
                    draft = newDraft
                }
            }
        }
    }

    private func indexOf(_ step: StepDraft) -> Int {
        draft.steps.firstIndex(where: { $0.id == step.id }) ?? 0
    }

    private func formatted(seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        let remainder = seconds % 60
        if remainder == 0 {
            return "\(minutes) min"
        }
        return String(format: "%d:%02d", minutes, remainder)
    }

    private func save() {
        switch mode {
        case .createNew:
            let recipe = draft.makeRecipe(isCustom: true, defaultImageURL: nil)
            onSave(recipe)
        case .editExisting(let existing):
            apply(draft, to: existing)
            onSave(existing)
        }
        dismiss()
    }

    private func apply(_ draft: RecipeDraft, to recipe: Recipe) {
        recipe.name = draft.name.trimmingCharacters(in: .whitespaces)
        if recipe.isCustom {
            recipe.author = "Custom"
        } else {
            let trimmed = draft.author.trimmingCharacters(in: .whitespaces)
            recipe.author = trimmed.isEmpty ? "Me" : trimmed
        }
        recipe.method = draft.method
        recipe.coffeeAmount = draft.coffeeAmount
        recipe.waterAmount = draft.waterAmount
        recipe.waterTemperature = draft.waterTemperature
        recipe.ratio = draft.ratio
        recipe.totalTime = draft.totalTime
        recipe.difficulty = draft.difficulty
        recipe.updatedAt = .now

        let existingImageURL = recipe.sortedSteps.first?.imageURL

        for old in recipe.sortedSteps {
            context.delete(old)
        }

        recipe.steps = draft.steps.enumerated().map { index, draftStep in
            Step(
                order: index + 1,
                title: draftStep.title.trimmingCharacters(in: .whitespaces),
                stepDescription: draftStep.detail.trimmingCharacters(in: .whitespaces),
                imageURL: existingImageURL,
                hasTimer: draftStep.hasTimer,
                timerDuration: draftStep.hasTimer ? draftStep.timerDuration : nil
            )
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
