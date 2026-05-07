import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                AsyncImage(url: URL(string: article.imageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color("BrandBorder")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()

                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(Self.dateFormatter.string(from: article.publishedAt))
                            .font(.subheadline)
                            .foregroundStyle(Color.brandTextSecondary)

                        Text(article.summary)
                            .font(.title3)
                            .foregroundStyle(Color.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                            .padding(.vertical, 4)

                        Text(article.body)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("BrandBackground"))
                } header: {
                    titleHeader
                }
            }
        }
        .scrollEdgeEffectStyle(nil, for: .top)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            CloseBottomBar { dismiss() }
        }
    }

    private var titleHeader: some View {
        Text(article.title)
            .font(.title.weight(.bold))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 70)
            .padding(.bottom, 14)
            .glassEffect(.regular, in: Rectangle())
    }
}
