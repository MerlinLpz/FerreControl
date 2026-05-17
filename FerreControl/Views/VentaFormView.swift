// Formulario para registrar la salida de stock — botón de confirmación terracota
import SwiftUI
import CoreData

struct VentaFormView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var producto: Producto
    @StateObject private var viewModel: VentaViewModel

    @State private var cantidad: Int = 1

    init(producto: Producto) {
        self.producto = producto
        _viewModel = StateObject(wrappedValue: VentaViewModel(context: producto.managedObjectContext!))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        Text(producto.nombreCompleto).foregroundStyle(Color.fcFg2)
                    } label: {
                        Text("Nombre").foregroundStyle(Color.fcFg2)
                    }
                    LabeledContent {
                        Text("\(producto.stock) \(producto.unidad ?? "unidades")")
                            .foregroundStyle(producto.stockBajo ? Color.fcWarning : Color.fcFg2)
                    } label: {
                        Text("Stock disponible").foregroundStyle(Color.fcFg2)
                    }
                    LabeledContent {
                        Text(producto.precio.enSoles).foregroundStyle(Color.fcFg2)
                    } label: {
                        Text("Precio unitario").foregroundStyle(Color.fcFg2)
                    }
                } header: {
                    Text("Producto").foregroundStyle(Color.fcFg2)
                }
                .listRowBackground(Color.fcBgCard)
                .listRowSeparatorTint(Color.fcSeparator)

                Section {
                    Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...Int(max(producto.stock, 1)))
                        .foregroundStyle(Color.fcFg)
                    LabeledContent {
                        Text((producto.precio * Double(cantidad)).enSoles)
                            .bold()
                            .foregroundStyle(Color.fcBrand)
                    } label: {
                        Text("Total").foregroundStyle(Color.fcFg2)
                    }
                } header: {
                    Text("Venta").foregroundStyle(Color.fcFg2)
                }
                .listRowBackground(Color.fcBgInput)
                .listRowSeparatorTint(Color.fcSeparator)

                Section {
                    Button(action: confirmarVenta) {
                        HStack {
                            Spacer()
                            Label("Confirmar venta", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.vertical, FCSpace.s1)
                    }
                    .disabled(producto.stock == 0)
                    .listRowBackground(producto.stock > 0 ? Color.fcBrand : Color.fcFg3)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.fcBgApp)
            .navigationTitle("Registrar Venta")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.fcBrand)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.fcFg2)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .presentationCornerRadius(FCRadius.sheet)
    }

    private func confirmarVenta() {
        viewModel.registrarVenta(producto: producto, cantidad: Int32(cantidad))
        if viewModel.errorMessage == nil { dismiss() }
    }
}
