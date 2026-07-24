import SwiftUI

struct AdminStoreFormView: View {
    @State private var viewModel: AdminStoreFormViewModel
    @Environment(\.dismiss) private var dismiss
    var onSaved: () -> Void

    init(store: Store? = nil, onSaved: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: AdminStoreFormViewModel(store: store))
        self.onSaved = onSaved
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section("Store") {
                TextField("Name", text: $viewModel.name)
                TextField("Address", text: $viewModel.address)
                Picker("Category", selection: $viewModel.category) {
                    ForEach(ProductCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                TextField("Latitude", text: $viewModel.latitude)
                    .keyboardType(.decimalPad)
                TextField("Longitude", text: $viewModel.longitude)
                    .keyboardType(.decimalPad)
                TextField("Open (HH:mm)", text: $viewModel.openTime)
                TextField("Close (HH:mm)", text: $viewModel.closeTime)
                TextField("Rating", text: $viewModel.rating)
                    .keyboardType(.decimalPad)
            }

            if !viewModel.isEditing {
                Section("Venue account") {
                    TextField("Username", text: $viewModel.accountUsername)
                    TextField("Email", text: $viewModel.accountEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Temporary password", text: $viewModel.temporaryPassword)
                    Text("Creates a venue login linked to this store. Share the temporary password securely.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if !viewModel.isEditing {
                    Button("Cancel") { dismiss() }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isEditing ? "Save" : "Create") {
                    Task {
                        await viewModel.save()
                        if viewModel.didSave {
                            onSaved()
                            dismiss()
                        }
                    }
                }
                .bold()
                .disabled(viewModel.isSaving)
            }
        }
    }
}
