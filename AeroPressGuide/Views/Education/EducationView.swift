import SwiftUI

private enum EducationSection: String, CaseIterable, Identifiable {
    case glossary, articles

    var id: String { rawValue }

    var label: String {
        switch self {
        case .glossary: return "Glossary"
        case .articles: return "Articles"
        }
    }
}

struct EducationView: View {
    @State private var section: EducationSection = .glossary
    @State private var searchText: String = ""
    @State private var selectedTerm: GlossaryTerm?
    @State private var selectedArticle: Article?

    private var filteredGlossary: [GlossaryTerm] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sorted = EducationContent.glossary.sorted {
            $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending
        }
        guard !trimmed.isEmpty else { return sorted }
        return sorted.filter {
            $0.term.localizedCaseInsensitiveContains(trimmed)
                || $0.shortDescription.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var filteredArticles: [Article] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sorted = EducationContent.articles.sorted { $0.publishedAt > $1.publishedAt }
        guard !trimmed.isEmpty else { return sorted }
        return sorted.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || $0.summary.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var groupedGlossary: [(letter: String, terms: [GlossaryTerm])] {
        let grouped = Dictionary(grouping: filteredGlossary) { term in
            String(term.term.prefix(1)).uppercased()
        }
        return grouped
            .map { (letter: $0.key, terms: $0.value) }
            .sorted { $0.letter < $1.letter }
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            EducationHeaderBar(searchText: $searchText, section: $section)
        }
        .fullScreenCover(item: $selectedTerm) { term in
            GlossaryDetailView(term: term)
        }
        .fullScreenCover(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .glossary:
            glossaryList
        case .articles:
            articlesList
        }
    }

    private var glossaryList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                if groupedGlossary.isEmpty {
                    emptyState(
                        title: "No terms found",
                        systemImage: "magnifyingglass"
                    )
                    .padding(.top, 80)
                } else {
                    ForEach(groupedGlossary, id: \.letter) { group in
                        Section {
                            VStack(spacing: 8) {
                                ForEach(group.terms) { term in
                                    Button {
                                        selectedTerm = term
                                    } label: {
                                        GlossaryTermRow(term: term)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } header: {
                            Text(group.letter)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.brandTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                                .background(.background)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(nil, for: .top)
    }

    private var articlesList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if filteredArticles.isEmpty {
                    emptyState(
                        title: "No articles found",
                        systemImage: "magnifyingglass"
                    )
                    .padding(.top, 80)
                } else {
                    ForEach(filteredArticles) { article in
                        Button {
                            selectedArticle = article
                        } label: {
                            ArticleCardView(article: article)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(nil, for: .top)
    }

    private func emptyState(title: String, systemImage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(Color.brandTextSecondary)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Header

private struct EducationHeaderBar: View {
    @Binding var searchText: String
    @Binding var section: EducationSection

    var body: some View {
        VStack(spacing: 10) {
            Picker("Section", selection: $section) {
                ForEach(EducationSection.allCases) { section in
                    Text(section.label).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .frame(height: 44)
            .padding(.horizontal, 16)

            EducationSearchField(searchText: $searchText)
                .padding(.horizontal, 16)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(alignment: .bottom) {
            VariableBlurView(maxBlurRadius: 10, direction: .blurredTopClearBottom)
                .frame(height: 190)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.88),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
        }
    }
}

private struct EducationSearchField: View {
    @Binding var searchText: String
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.brandTextSecondary)

            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .focused($focused)
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(.regular.interactive(), in: Capsule())
    }
}

// MARK: - Rows

private struct GlossaryTermRow: View {
    let term: GlossaryTerm

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(term.term)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(term.shortDescription)
                    .font(.subheadline)
                    .foregroundStyle(Color.brandTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(14)
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("BrandPrimary").opacity(0.06), radius: 6, y: 2)
    }
}

private struct ArticleCardView: View {
    let article: Article

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: article.imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color("BrandBorder")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(Self.dateFormatter.string(from: article.publishedAt))
                    .font(.caption)
                    .foregroundStyle(Color.brandTextSecondary)

                Text(article.summary)
                    .font(.subheadline)
                    .foregroundStyle(Color.brandTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.top, 2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("BrandPrimary").opacity(0.08), radius: 8, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}
