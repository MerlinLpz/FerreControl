// Vista dedicada a productos con stock bajo — muestra urgencia y permite acceder al detalle
import SwiftUI

struct AlertasView: View {

    @ObservedObject var viewModel: ProductoViewModel

    var body: some View {
        Group {
            if viewModel.productosStockBajo.isEmpty {
                inventarioEnOrden
            } else {
                listaAlertas
            }
        }
        .navigationTitle("Alertas de stock")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Estado vacío

    private var inventarioEnOrden: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Todo en orden")
                .font(.title2.bold())
            Text("Todos los productos tienen stock suficiente.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Lista de alertas

    private var listaAlertas: some View {
        List {
            Section {
                resumenCabecera
            }

            let agotados  = viewModel.productosStockBajo.filter { $0.stock == 0 }
            let criticos  = viewModel.productosStockBajo.filter { $0.stock > 0 && $0.stock <= $0.stockMinimo / 2 }
            let bajos     = viewModel.productosStockBajo.filter { $0.stock > $0.stockMinimo / 2 }

            if !agotados.isEmpty {
                Section {
                    ForEach(agotados) { p in
                        filaAlerta(p, nivel: .agotado)
                    }
                } header: {
                    etiquetaSeccion("Agotados", icono: "xmark.circle.fill", color: .red)
                }
            }

            if !criticos.isEmpty {
                Section {
                    ForEach(criticos) { p in
                        filaAlerta(p, nivel: .critico)
                    }
                } header: {
                    etiquetaSeccion("Crítico", icono: "exclamationmark.triangle.fill", color: .orange)
                }
            }

            if !bajos.isEmpty {
                Section {
                    ForEach(bajos) { p in
                        filaAlerta(p, nivel: .bajo)
                    }
                } header: {
                    etiquetaSeccion("Stock bajo", icono: "arrow.down.circle.fill", color: .yellow)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Subcomponentes

    private var resumenCabecera: some View {
        HStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.productosStockBajo.count) producto\(viewModel.productosStockBajo.count == 1 ? "" : "s") con stock bajo")
                    .font(.headline)
                Text("Revisa y repón el inventario")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func etiquetaSeccion(_ titulo: String, icono: String, color: Color) -> some View {
        Label(titulo, systemImage: icono)
            .foregroundStyle(color)
            .font(.caption.bold())
            .textCase(nil)
    }

    private func filaAlerta(_ producto: Producto, nivel: NivelAlerta) -> some View {
        NavigationLink(destination: ProductoDetailView(producto: producto, viewModel: viewModel)) {
            FilaProductoAlerta(producto: producto, nivel: nivel)
        }
    }
}

// MARK: - Fila de producto en alertas

private struct FilaProductoAlerta: View {
    let producto: Producto
    let nivel: NivelAlerta

    /// Porcentaje de stock respecto al mínimo (máximo 1.0)
    private var progreso: Double {
        guard producto.stockMinimo > 0 else { return 0 }
        return min(Double(producto.stock) / Double(producto.stockMinimo), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(producto.nombreCompleto)
                        .font(.headline)
                    Text(producto.unidad ?? "Unidad")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(producto.stock)")
                        .font(.title3.bold())
                        .foregroundStyle(nivel.color)
                    Text("mín. \(producto.stockMinimo)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Barra de progreso que muestra qué tan cerca está del mínimo
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(nivel.color.gradient)
                        .frame(width: geo.size.width * progreso, height: 6)
                }
            }
            .frame(height: 6)

            Text(nivel.descripcion(stock: producto.stock, minimo: producto.stockMinimo,
                                   unidad: producto.unidad ?? "unidades"))
                .font(.caption)
                .foregroundStyle(nivel.color)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Niveles de alerta

private enum NivelAlerta {
    case agotado, critico, bajo

    var color: Color {
        switch self {
        case .agotado: .red
        case .critico: .orange
        case .bajo:    .yellow
        }
    }

    func descripcion(stock: Int32, minimo: Int32, unidad: String) -> String {
        switch self {
        case .agotado:
            return "Sin stock — reponer urgente"
        case .critico:
            let faltan = minimo - stock
            return "Faltan \(faltan) \(unidad.lowercased()) para alcanzar el mínimo"
        case .bajo:
            let faltan = minimo - stock
            return "Faltan \(faltan) \(unidad.lowercased()) para alcanzar el mínimo"
        }
    }
}
