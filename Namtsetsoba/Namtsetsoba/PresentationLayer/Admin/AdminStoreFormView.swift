import MapKit
import PhotosUI
import SwiftUI
import UIKit

// MARK: - Edit host (presented as a sheet from the stores list)

struct AdminStoreFormView: View {
    @State private var viewModel: AdminStoreFormViewModel
    @Environment(\.dismiss) private var dismiss
    var onSaved: () -> Void

    init(store: Store? = nil, onSaved: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: AdminStoreFormViewModel(store: store))
        self.onSaved = onSaved
    }

    var body: some View {
        ScrollView {
            StoreFormContent(viewModel: viewModel)
                .padding(20)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L(.commonCancel)) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isEditing ? L(.commonSave) : L(.commonCreate)) {
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

// MARK: - Add Venue tab (admin)

struct AdminAddVenueView: View {
    @State private var viewModel = AdminStoreFormViewModel()
    @State private var formToken = UUID()
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    StoreFormContent(viewModel: viewModel)
                        .id(formToken)
                    createButton
                }
                .padding(20)
                .floatingTabBarScrollFiller()
            }
            .background(DesignTokens.selectedChipBackground)
            .navigationTitle(L(.tabAddVenue))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .overlay(alignment: .top) {
                if showSuccess { successToast }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSuccess)
        }
    }

    private var createButton: some View {
        Button {
            Task {
                await viewModel.save()
                if viewModel.didSave {
                    viewModel.reset()
                    formToken = UUID()
                    showSuccess = true
                    try? await Task.sleep(for: .seconds(2.5))
                    showSuccess = false
                }
            }
        } label: {
            ZStack {
                if viewModel.isSaving {
                    ProgressView().tint(.white)
                } else {
                    Label(L(.formCreateVenue), systemImage: "checkmark.circle.fill")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(DesignTokens.headerGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: DesignTokens.primaryGreen.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    private var successToast: some View {
        Label(L(.formVenueCreated), systemImage: "checkmark.seal.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Capsule().fill(DesignTokens.primaryGreen))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Shared branded form

private struct StoreFormContent: View {
    @Bindable var viewModel: AdminStoreFormViewModel

    @State private var photoItem: PhotosPickerItem?
    @State private var previewImage: Image?
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var coordinate: CLLocationCoordinate2D? {
        guard let lat = viewModel.parsedLatitude, let lon = viewModel.parsedLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var body: some View {
        VStack(spacing: 18) {
            if !viewModel.isEditing { photoCard }
            detailsCard
            locationCard
            hoursCard
            if !viewModel.isEditing { accountCard }

            if let error = viewModel.errorMessage {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.red)
                .padding(12)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .onAppear(perform: centerMap)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await loadPhoto(item) }
        }
    }

    // MARK: Cards

    private var photoCard: some View {
        card(L(.formStorePhoto), icon: "photo.on.rectangle.angled") {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color(.secondarySystemBackground))
                    if let previewImage {
                        previewImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(DesignTokens.primaryGreen.opacity(0.6))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color(.separator).opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    Text(L(.formPhotoHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(previewImage == nil ? L(.formChoosePhoto) : L(.formChangePhoto),
                              systemImage: "photo")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var detailsCard: some View {
        card(L(.formStoreDetails), icon: "storefront.fill") {
            field(L(.formName), text: $viewModel.name)
            field(L(.formAddress), text: $viewModel.address)
            Menu {
                ForEach(ProductCategory.allCases) { category in
                    Button {
                        viewModel.category = category
                    } label: {
                        Text("\(category.icon)  \(category.localizedName)")
                    }
                }
            } label: {
                HStack {
                    Text("\(viewModel.category.icon)  \(viewModel.category.localizedName)")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var locationCard: some View {
        card(L(.formLocation), icon: "mappin.and.ellipse") {
            Text(L(.formTapMap))
                .font(.caption)
                .foregroundStyle(.secondary)

            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let coordinate {
                        Marker("", coordinate: coordinate)
                            .tint(DesignTokens.primaryGreen)
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onTapGesture { location in
                    if let coordinate = proxy.convert(location, from: .local) {
                        viewModel.setCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    }
                }
            }

            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.primaryGreen)
                Text(viewModel.hasCoordinate
                     ? "\(viewModel.latitude), \(viewModel.longitude)"
                     : L(.formNoLocation))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var hoursCard: some View {
        card(L(.formOpeningHours), icon: "clock.fill") {
            DatePicker(L(.formOpens), selection: $viewModel.openTimeDate, displayedComponents: .hourAndMinute)
            DatePicker(L(.formCloses), selection: $viewModel.closeTimeDate, displayedComponents: .hourAndMinute)
        }
    }

    private var accountCard: some View {
        card(L(.formVenueAccount), icon: "person.badge.key.fill") {
            field(L(.authUsername), text: $viewModel.accountUsername, autocap: .never)
            field(L(.authEmail), text: $viewModel.accountEmail, keyboard: .emailAddress, autocap: .never)
            SecureField(L(.formTempPassword), text: $viewModel.temporaryPassword)
                .textContentType(.oneTimeCode)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(L(.formAccountHint))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Building blocks

    private func card<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryGreen)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func field(
        _ placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autocap: TextInputAutocapitalization = .sentences
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(autocap)
            .autocorrectionDisabled(keyboard == .emailAddress)
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: Actions

    private func centerMap() {
        guard let coordinate else { return }
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        )
    }

    private func loadPhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let jpeg = uiImage.jpegData(compressionQuality: 0.85) else { return }
        viewModel.photoData = jpeg
        previewImage = Image(uiImage: uiImage)
    }
}
