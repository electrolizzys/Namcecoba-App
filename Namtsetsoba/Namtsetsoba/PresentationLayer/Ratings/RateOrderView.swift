import SwiftUI

/// Prompts the customer to rate a store after they collect an order.
struct RateOrderView: View {
    let order: Order

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RateOrderViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                header
                starPicker
                commentField

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)
                submitButton
            }
            .padding(DesignTokens.padding)
            .background(DesignTokens.selectedChipBackground)
            .navigationTitle("Rate your pickup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var header: some View {
        VStack(spacing: 8) {
            StoreThumbnailView(store: order.basket.store, size: 64)
            Text(order.basket.store.name)
                .font(.title3.bold())
            Text("How was “\(order.basket.title)”?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var starPicker: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        viewModel.stars = index
                    }
                } label: {
                    Image(systemName: index <= viewModel.stars ? "star.fill" : "star")
                        .font(.system(size: 34))
                        .foregroundStyle(index <= viewModel.stars ? DesignTokens.accentOrange : .secondary)
                        .scaleEffect(index == viewModel.stars ? 1.15 : 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(index) star\(index == 1 ? "" : "s")")
            }
        }
    }

    private var commentField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Add a comment (optional)")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("What stood out?", text: $viewModel.comment, axis: .vertical)
                .lineLimit(2...4)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius))
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submit() }
        } label: {
            if viewModel.isSubmitting {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Submit rating")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(
            viewModel.canSubmit ? DesignTokens.primaryGreen : Color.gray,
            in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
        )
        .disabled(!viewModel.canSubmit)
    }

    @MainActor
    private func submit() async {
        guard let userId = appState.userId else {
            viewModel.errorMessage = "Please sign in again to rate."
            return
        }
        let success = await viewModel.submit(
            orderId: order.id,
            storeId: order.basket.store.id,
            userId: userId
        )
        if success {
            appState.markOrderRated(order.id)
            dismiss()
        }
    }
}
