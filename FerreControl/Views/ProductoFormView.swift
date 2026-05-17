// Formulario para agregar o editar un producto del inventario
import SwiftUI

struct ProductoFormView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductoViewModel

    /// Si se pasa un producto existente, el formulario entra en modo edición
    var productoEditar: Producto?

    @State private var nombre: String = ""
    @State private var medida: String = ""
    @State private var unidadSeleccionada: String = UnidadMedida.unidad.rawValue
    @State private var stockTexto: String = "0"
    @State private var stockMinimoTexto: String = "5"
    @State private var precioTexto: String = "0.00"

    @State private var mostrarError = false
    @State private var mensajeError = ""

    private var esModoEdicion: Bool { productoEditar != nil }

    var body: some View {
        NavigationStack {
            Form {
                seccionIdentificacion
                seccionInventario
                seccionPrecio
            }
            .navigationTitle(esModoEdicion ? "Editar Producto" : "Nuevo Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .bold()
                }
            }
            .alert("Datos incompletos", isPresented: $mostrarError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(mensajeError)
            }
            .onAppear { cargarDatosEdicion() }
        }
    }

    // MARK: - Secciones del formulario

    private var seccionIdentificacion: some View {
        Section("Identificación") {
            LabeledContent("Nombre") {
                TextField("Ej: Tornillo, Tubería, Pintura", text: $nombre)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Medida") {
                TextField("Ej: 1/2 pulgada, 3/4\"", text: $medida)
                    .multilineTextAlignment(.trailing)
            }
            Picker("Unidad de venta", selection: $unidadSeleccionada) {
                ForEach(UnidadMedida.allCases, id: \.rawValue) { unidad in
                    Text(unidad.rawValue).tag(unidad.rawValue)
                }
            }
        }
    }

    private var seccionInventario: some View {
        Section("Inventario") {
            LabeledContent("Stock actual") {
                TextField("0", text: $stockTexto)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Stock mínimo") {
                TextField("5", text: $stockMinimoTexto)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                Text("Se mostrará una alerta cuando el stock baje del mínimo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var seccionPrecio: some View {
        Section("Precio") {
            LabeledContent("Precio (S/)") {
                TextField("0.00", text: $precioTexto)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    // MARK: - Lógica

    private func cargarDatosEdicion() {
        guard let p = productoEditar else { return }
        nombre = p.nombre ?? ""
        medida = p.medida ?? ""
        unidadSeleccionada = p.unidad ?? UnidadMedida.unidad.rawValue
        stockTexto = "\(p.stock)"
        stockMinimoTexto = "\(p.stockMinimo)"
        precioTexto = String(format: "%.2f", p.precio)
    }

    private func guardar() {
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            mensajeError = "El nombre del producto es obligatorio."
            mostrarError = true
            return
        }
        guard let stock = Int32(stockTexto), let stockMin = Int32(stockMinimoTexto) else {
            mensajeError = "Ingresa valores numéricos válidos para el stock."
            mostrarError = true
            return
        }
        let precio = Double(precioTexto.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        if let p = productoEditar {
            viewModel.actualizarProducto(p, nombre: nombre, medida: medida,
                                         unidad: unidadSeleccionada, stock: stock,
                                         stockMinimo: stockMin, precio: precio)
        } else {
            viewModel.agregarProducto(nombre: nombre, medida: medida,
                                      unidad: unidadSeleccionada, stock: stock,
                                      stockMinimo: stockMin, precio: precio)
        }
        dismiss()
    }
}
