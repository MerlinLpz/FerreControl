// Formulario para registrar la salida de stock por una venta
import SwiftUI
import CoreData

struct VentaFormView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var producto: Producto
    @StateObject private var viewModel: VentaViewModel

    @State private var cantidad: Int = 1

    init(producto: Producto) {
        self.producto = producto
        // Se inicializa después de que @Environment esté disponible,
        // por eso usamos un placeholder temporal que se reasigna en onAppear
        _viewModel = StateObject(wrappedValue: VentaViewModel(context: producto.managedObjectContext!))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Producto") {
                    LabeledContent("Nombre", value: producto.nombreCompleto)
                    LabeledContent("Stock disponible") {
                        Text("\(producto.stock) \(producto.unidad ?? "unidades")")
                            .foregroundStyle(producto.stockBajo ? .orange : .primary)
                    }
                    LabeledContent("Precio unitario", value: producto.precio.enSoles)
                }

                Section("Venta") {
                    Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...Int(max(producto.stock, 1)))
                    LabeledContent("Total") {
                        Text((producto.precio * Double(cantidad)).enSoles)
                            .bold()
                    }
                }

                Section {
                    Button(action: confirmarVenta) {
                        HStack {
                            Spacer()
                            Label("Confirmar venta", systemImage: "checkmark.circle.fill")
                                .bold()
                            Spacer()
                        }
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.blue)
                    .disabled(producto.stock == 0)
                }
            }
            .navigationTitle("Registrar Venta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
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
    }

    private func confirmarVenta() {
        viewModel.registrarVenta(producto: producto, cantidad: Int32(cantidad))
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}
