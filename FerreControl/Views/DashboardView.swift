// Pantalla de resumen: estadísticas clave del inventario y ventas recientes
import SwiftUI

struct DashboardView: View {

    @ObservedObject var viewModel: ProductoViewModel

    private let columnas = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FCSpace.s6) {
                    encabezado
                    seccionEstadisticas
                    if viewModel.productoMasVendido != nil {
                        seccionProductoEstrella
                    }
                    seccionVentasRecientes
                }
                .padding(FCSpace.s4)
            }
            .navigationTitle("Resumen")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.fcBgApp)
            .toolbarBackground(Color.fcBgApp, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: FCSpace.s1) {
            Text(saludo)
                .font(.title2.bold())
                .foregroundStyle(Color.fcFg)
            Text(Date().conHora)
                .font(.subheadline)
                .foregroundStyle(Color.fcFg3)
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
        LazyVGrid(columns: columnas, spacing: FCSpace.s4) {
            TarjetaStat(
                titulo: "Productos",
                valor: "\(viewModel.productos.count)",
                icono: "archivebox.fill",
                color: .fcBrand
            )
            TarjetaStat(
                titulo: "Valor inventario",
                valor: viewModel.valorTotalInventario.enSoles,
                icono: "peruniansol",
                color: .fcSuccess
            )
            TarjetaStat(
                titulo: "En alerta",
                valor: "\(viewModel.productosStockBajo.count)",
                icono: "exclamationmark.triangle.fill",
                color: viewModel.productosStockBajo.isEmpty ? .fcFg3 : .fcWarning
            )
            TarjetaStat(
                titulo: "Unidades vendidas",
                valor: "\(viewModel.totalUnidadesVendidas)",
                icono: "cart.fill",
                color: .fcBrand2
            )
        }
    }

    // MARK: - Producto estrella

    private var seccionProductoEstrella: some View {
        VStack(alignment: .leading, spacing: FCSpace.s3) {
            Label("Producto más vendido", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(Color.fcFg)

            if let top = viewModel.productoMasVendido {
                NavigationLink(destination: ProductoDetailView(producto: top, viewModel: viewModel)) {
                    HStack(spacing: FCSpace.s4) {
                        ZStack {
                            Circle()
                                .fill(Color.fcWarningBg)
                                .frame(width: 52, height: 52)
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundStyle(Color.fcWarning)
                        }
                        VStack(alignment: .leading, spacing: FCSpace.s1) {
                            Text(top.nombreCompleto)
                                .font(.headline)
                                .foregroundStyle(Color.fcFg)
                            Text("\(top.totalVendido) \((top.unidad ?? "unidades").lowercased()) vendidas")
                                .font(.subheadline)
                                .foregroundStyle(Color.fcFg2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.fcFg3)
                    }
                    .padding(FCSpace.s4)
                    .background(Color.fcBgCard)
                    .clipShape(RoundedRectangle(cornerRadius: FCRadius.card))
                    .shadow(color: Color.fcFg.opacity(0.06), radius: 8, x: 0, y: 2)
                }
            }
        }
    }

    // MARK: - Ventas recientes

    private var seccionVentasRecientes: some View {
        VStack(alignment: .leading, spacing: FCSpace.s3) {
            Label("Últimas ventas", systemImage: "clock.arrow.circlepath")
                .font(.headline)
                .foregroundStyle(Color.fcFg)

            if viewModel.ventasRecientes.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: FCSpace.s2) {
                        Image(systemName: "cart.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundStyle(Color.fcFg3)
                        Text("Sin ventas registradas")
                            .font(.subheadline)
                            .foregroundStyle(Color.fcFg3)
                    }
                    .padding(FCSpace.s5)
                    Spacer()
                }
                .background(Color.fcBgCard)
                .clipShape(RoundedRectangle(cornerRadius: FCRadius.card))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.ventasRecientes.enumerated()), id: \.element.objectID) { idx, venta in
                        FilaVentaReciente(venta: venta)
                        if idx < viewModel.ventasRecientes.count - 1 {
                            Divider()
                                .overlay(Color.fcSeparator)
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color.fcBgCard)
                .clipShape(RoundedRectangle(cornerRadius: FCRadius.card))
                .shadow(color: Color.fcFg.opacity(0.06), radius: 8, x: 0, y: 2)
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
        VStack(alignment: .leading, spacing: FCSpace.s3) {
            ZStack {
                RoundedRectangle(cornerRadius: FCRadius.sm)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icono)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: FCSpace.s1) {
                Text(valor)
                    .font(.title2.bold())
                    .foregroundStyle(Color.fcFg)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(titulo)
                    .font(.caption)
                    .foregroundStyle(Color.fcFg3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FCSpace.s4)
        .background(Color.fcBgCard)
        .clipShape(RoundedRectangle(cornerRadius: FCRadius.card))
        .shadow(color: Color.fcFg.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Fila de venta reciente

private struct FilaVentaReciente: View {
    let venta: Venta

    var body: some View {
        HStack(spacing: FCSpace.s3) {
            ZStack {
                Circle()
                    .fill(Color.fcBrandSoft)
                    .frame(width: 36, height: 36)
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(Color.fcBrand)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(venta.producto?.nombreCompleto ?? "Producto eliminado")
                    .font(.subheadline)
                    .foregroundStyle(Color.fcFg)
                    .lineLimit(1)
                Text(venta.fecha?.corta ?? "—")
                    .font(.caption)
                    .foregroundStyle(Color.fcFg3)
            }
            Spacer()
            Text("-\(venta.cantidad) \((venta.producto?.unidad ?? "uds.").lowercased())")
                .font(.subheadline.bold())
                .foregroundStyle(Color.fcDanger)
        }
        .padding(.horizontal, FCSpace.s4)
        .padding(.vertical, FCSpace.s3)
    }
}
