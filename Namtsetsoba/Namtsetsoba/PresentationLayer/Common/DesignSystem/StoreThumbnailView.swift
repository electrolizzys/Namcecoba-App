import SwiftUI

/// Square thumbnail for list rows (logo or category fallback).
struct StoreThumbnailView: View {
    let store: Store
    var size: CGFloat = 60
    var cornerRadius: CGFloat = DesignTokens.smallCornerRadius

    var body: some View {
        Group {
            if let urlString = store.logoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        fallback
                    default:
                        fallback
                            .overlay {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                    }
                }
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .id(urlString)
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
    }

    private var fallback: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DesignTokens.gradientForCategory(store.category))
                .frame(width: size, height: size)
            Text(store.category.icon)
                .font(.system(size: size * 0.38))
        }
    }
}

/// Wide branded strip for basket cards and hero headers (logo photo or gradient).
struct StoreBannerImage: View {
    let store: Store
    var height: CGFloat = 130

    var body: some View {
        Group {
            if let urlString = store.logoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        fallback
                    default:
                        fallback
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    }
                }
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()
                .id(urlString)
            } else {
                fallback
            }
        }
        .frame(height: height)
    }

    private var fallback: some View {
        DesignTokens.gradientForCategory(store.category)
            .frame(height: height)
            .overlay {
                Text(store.category.icon)
                    .font(.system(size: height * 0.43))
                    .opacity(0.25)
            }
    }
}
