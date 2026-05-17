// Pantalla de resumen: estadísticas clave del inventario y ventas recientes
import SwiftUI

struct DashboardView: View {

    @ObservedObject var viewModel: ProductoViewModel

    private let columnas = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    encabezado
                    seccionEstadisticas
                    if viewModel.productoMasVendido != nil {
                        seccionProductoEstrella
                    }
                    seccionVentasRecientes
                }
                .padding()
            }
            .navigationTitle("Resumen")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(saludo)
                .font(.title2.bold())
            Text(Date().conHora)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var saludo: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 5..<12:  return "Buenos días"
        case 12..<18: return "Buenas tardes"
        default:      return "Buenas noches"
        }
    }

    // MARK: - Tarjetas de estadísticas

    private var seccionEstadisticas: some View {
        LazyVGrid(columns: columnas, spacing: 16) {
            TarjetaStat(
                titulo: "Productos",
                valor: "\(viewModel.productos.count)",
                icono: "archivebox.fill",
                color: .blue
            )
            TarjetaStat(
                titulo: "Valor inventario",
                valor: viewModel.valorTotalInventario.enSoles,
                icono: "peruniansol",
                color: .green
            )
            TarjetaStat(
                titulo: "En alerta",
                valor: "\(viewModel.productosStockBajo.count)",
                icono: "exclamationmark.triangle.fill",
                color: viewModel.productosStockBajo.isEmpty ? .gray : .orange
            )
            TarjetaStat(
                titulo: "Unidades vendidas",
                valor: "\(viewModel.totalUnidadesVendidas)",
                icono: "cart.fill",
                color: .purple
            )
        }
    }

    // MARK: - Producto estrella

    private var seccionProductoEstrella: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Producto más vendido", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            if let top = viewModel.productoMasVendido {
                NavigationLink(destination: ProductoDetailView(producto: top, viewModel: viewModel)) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 52, height: 52)
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(top.nombreCompleto)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("\(top.totalVendido) \((top.unidad ?? "unidades").lowercased()) vendidas")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Ventas recientes

    private var seccionVentasRecientes: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Últimas ventas", systemImage: "clock.arrow.circlepath")
                .font(.headline)

            if viewModel.ventasRecientes.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "cart.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Sin ventas registradas")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    Spacer()
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.ventasRecientes.enumerated()), id: \.element.objectID) { idx, venta in
                        FilaVentaReciente(venta: venta)
                        if idx < viewModel.ventasRecientes.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

// MARK: - Tarjeta de estadística

private struct TarjetaStat: View {
    let titulo: String
    let valor: String
    let icono: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icono)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(valor)
                    .font(.title2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(titulo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Fila de venta reciente

private struct FilaVentaReciente: View {
    let venta: Venta

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.purple)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(venta.producto?.nombreCompleto ?? "Producto eliminado")
                    .font(.subheadline)
                    .lineLimit(1)
                Text(venta.fecha?.corta ?? "—")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("-\(venta.cantidad) \((venta.producto?.unidad ?? "uds.").lowercased())")
                .font(.subheadline.bold())
                .foregroundStyle(.red)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
