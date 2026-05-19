// Formulario para agregar o editar un producto — fondo kraft con inputs fcBgInput
import SwiftUI

struct ProductoFormView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductoViewModel
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
                seccionGuardar
            }
            .scrollContentBackground(.hidden)
            .background(Color.fcBgApp)
            .navigationTitle(esModoEdicion ? "Editar Producto" : "Nuevo Producto")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.fcBrand)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.fcFg2)
                }
            }
            .alert("Datos incompletos", isPresented: $mostrarError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(mensajeError)
            }
            .onAppear { cargarDatosEdicion() }
        }
        .presentationCornerRadius(FCRadius.sheet)
    }

    // MARK: - Secciones

    private var seccionIdentificacion: some View {
        Section {
            campo("Nombre", placeholder: "Ej: Tornillo, Tubería", texto: $nombre)
            campo("Medida", placeholder: "Ej: 1/2 pulgada, 3/4\"", texto: $medida)
            Picker(selection: $unidadSeleccionada) {
                ForEach(UnidadMedida.allCases, id: \.rawValue) { u in
                    Text(u.rawValue).tag(u.rawValue)
                }
            } label: {
                Text("Unidad de venta").foregroundStyle(Color.fcFg2)
            }
        } header: {
            Text("Identificación").foregroundStyle(Color.fcFg2)
        }
        .listRowBackground(Color.fcBgInput)
        .listRowSeparatorTint(Color.fcSeparator)
    }

    private var seccionInventario: some View {
        Section {
            campoNumero("Stock actual", placeholder: "0", texto: $stockTexto)
            campoNumero("Stock mínimo", placeholder: "5", texto: $stockMinimoTexto)
            HStack(alignment: .top, spacing: FCSpace.s2) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.fcBrand)
                Text("Se mostrará una alerta cuando el stock baje del mínimo.")
                    .font(.caption)
                    .foregroundStyle(Color.fcFg3)
            }
        } header: {
            Text("Inventario").foregroundStyle(Color.fcFg2)
                
        }
        .listRowBackground(Color.fcBgInput)
        .listRowSeparatorTint(Color.fcSeparator)
    }

    private var seccionPrecio: some View {
        Section {
            campoDecimal("Precio (S/)", placeholder: "0.00", texto: $precioTexto)
        } header: {
            Text("Precio").foregroundStyle(Color.fcFg2)
        }
        .listRowBackground(Color.fcBgInput)
        .listRowSeparatorTint(Color.fcSeparator)
    }

    private var seccionGuardar: some View {
        Section {
            Button(action: guardar) {
                HStack {
                    Spacer()
                    Text(esModoEdicion ? "Guardar cambios" : "Agregar producto")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.vertical, FCSpace.s1)
            }
            .listRowBackground(Color.fcBrand)
        }
    }

    // MARK: - Campos reutilizables

    private func campo(_ label: String, placeholder: String, texto: Binding<String>) -> some View {
        LabeledContent {
            TextField(placeholder, text: texto)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.fcFg)
        } label: {
            Text(label).foregroundStyle(Color.fcFg2)
        }
    }

    private func campoNumero(_ label: String, placeholder: String, texto: Binding<String>) -> some View {
        LabeledContent {
            TextField(placeholder, text: texto)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.fcFg)
        } label: {
            Text(label).foregroundStyle(Color.fcFg2)
        }
    }

    private func campoDecimal(_ label: String, placeholder: String, texto: Binding<String>) -> some View {
        LabeledContent {
            TextField(placeholder, text: texto)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.fcFg)
        } label: {
            Text(label).foregroundStyle(Color.fcFg2)
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
