// Vista de detalle: información del producto e historial de ventas
import SwiftUI

struct ProductoDetailView: View {

    @ObservedObject var producto: Producto
    @ObservedObject var viewModel: ProductoViewModel

    @State private var mostrarEdicion = false
    @State private var mostrarVenta = false

    var body: some View {
        List {
            seccionInfo
            seccionVentas
        }
        .listStyle(.insetGrouped)
        .navigationTitle(producto.nombreCompleto)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") { mostrarEdicion = true }
            }
        }
        .sheet(isPresented: $mostrarEdicion) {
            ProductoFormView(viewModel: viewModel, productoEditar: producto)
        }
        .sheet(isPresented: $mostrarVenta) {
            VentaFormView(producto: producto)
        }
    }

    // MARK: - Secciones

    private var seccionInfo: some View {
        Section("Información") {
            FilaDetalle(icono: "tag", etiqueta: "Medida", valor: producto.medida ?? "—")
            FilaDetalle(icono: "square.grid.2x2", etiqueta: "Unidad", valor: producto.unidad ?? "—")
            FilaDetalle(icono: "peruniansol", etiqueta: "Precio", valor: producto.precio.enSoles)

            HStack {
                Label("Stock actual", systemImage: "archivebox")
                Spacer()
                Text("\(producto.stock)")
                    .bold()
                    .foregroundStyle(producto.stockBajo ? .red : .primary)
                if producto.stockBajo {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            FilaDetalle(icono: "arrow.down.to.line", etiqueta: "Stock mínimo", valor: "\(producto.stockMinimo)")
            FilaDetalle(icono: "cart", etiqueta: "Total vendido", valor: "\(producto.totalVendido) \(producto.unidad ?? "unidades")")

            // Botón para registrar una nueva venta
            Button {
                mostrarVenta = true
            } label: {
                Label("Registrar venta", systemImage: "minus.circle")
                    .foregroundStyle(producto.stock > 0 ? .blue : .gray)
            }
            .disabled(producto.stock == 0)
        }
    }

    private var seccionVentas: some View {
        Section("Historial de ventas (\(producto.ventasArray.count))") {
            if producto.ventasArray.isEmpty {
                Text("Sin ventas registradas")
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(producto.ventasArray) { venta in
                    FilaVenta(venta: venta, unidad: producto.unidad ?? "")
                }
            }
        }
    }
}

// MARK: - Fila de detalle genérica

private struct FilaDetalle: View {
    let icono: String
    let etiqueta: String
    let valor: String

    var body: some View {
        Label {
            HStack {
                Text(etiqueta)
                Spacer()
                Text(valor)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icono)
        }
    }
}

// MARK: - Fila de venta en el historial

private struct FilaVenta: View {
    let venta: Venta
    let unidad: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(venta.fecha?.corta ?? "Fecha desconocida")
                    .font(.subheadline)
                Text(venta.fecha?.conHora ?? "")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Text("-\(venta.cantidad) \(unidad.lowercased())")
                .font(.subheadline.bold())
                .foregroundStyle(.red)
        }
    }
}
