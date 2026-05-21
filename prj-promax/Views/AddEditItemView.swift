import SwiftUI

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ItemViewModel
    var editItem: ItemDomain?

    @State private var name = ""
    @State private var desc = ""
    @State private var price = ""
    @State private var imageUrl = ""

    private var isEditing: Bool { editItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Info") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $desc)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Image URL", text: $imageUrl)
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { save() }
                        .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .onAppear {
                if let item = editItem {
                    name = item.name
                    desc = item.desc
                    price = String(format: "%.2f", item.price)
                    imageUrl = item.imageUrl
                }
            }
        }
    }

    private func save() {
        let p = Double(price) ?? 0
        if let item = editItem {
            viewModel.updateItem(item, name: name, desc: desc, price: p, imageUrl: imageUrl)
        } else {
            viewModel.addItem(name: name, desc: desc, price: p, imageUrl: imageUrl)
        }
        dismiss()
    }
}

#Preview {
    AddEditItemView(viewModel: ItemViewModel(), editItem: nil)
}

#Preview {
    AddEditItemView(viewModel: ItemViewModel(), editItem: ItemDomain(id: "1", name: "Sample", desc: "Sample item", price: 19.99, imageUrl: "", createdAt: Date()))
}
