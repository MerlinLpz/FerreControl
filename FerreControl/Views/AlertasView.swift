// Vista de alertas con niveles de urgencia y colores semánticos del sistema de diseño
import SwiftUI

struct AlertasView: View {

    @ObservedObject var viewModel: ProductoViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.productosStockBajo.isEmpty {
                    inventarioEnOrden
                } else {
                    listaAlertas
                }
            }
            .navigationTitle("Alertas")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .background(Color.fcBgApp)
            .toolbarBackground(Color.fcBgApp, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Estado vacío

    private var inventarioEnOrden: some View {
        VStack(spacing: FCSpace.s5) {
            ZStack {
                Circle()
                    .fill(Color.fcSuccessBg)
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.fcSuccess)
            }
            VStack(spacing: FCSpace.s2) {
                Text("Todo en orden")
                    .font(.title2.bold())
                    .foregroundStyle(Color.fcFg)
                Text("Todos los productos tienen\nstock suficiente.")
                    .font(.subheadline)
                    .foregroundStyle(Color.fcFg2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.fcBgApp)
    }

    // MARK: - Lista de alertas

    private var listaAlertas: some View {
        List {
            Section {
                resumenCabecera
            }
            .listRowBackground(Color.fcBrandSoft)
            .listRowSeparator(.hidden)

            let agotados = viewModel.productosStockBajo.filter { $0.stock == 0 }
            let criticos = viewModel.productosStockBajo.filter { $0.stock > 0 && $0.stock <= $0.stockMinimo / 2 }
            let bajos    = viewModel.productosStockBajo.filter { $0.stock > $0.stockMinimo / 2 }

            if !agotados.isEmpty {
                Section {
                    ForEach(agotados) { p in filaAlerta(p, nivel: .agotado) }
                } header: {
                    etiquetaSeccion("Agotados", icono: "xmark.circle.fill", color: .fcDanger)
                }
                .listRowBackground(Color.fcBgCard)
                .listRowSeparatorTint(Color.fcSeparator)
            }

            if !criticos.isEmpty {
                Section {
                    ForEach(criticos) { p in filaAlerta(p, nivel: .critico) }
                } header: {
                    etiquetaSeccion("Crítico", icono: "exclamationmark.triangle.fill", color: .fcWarning)
                }
                .listRowBackground(Color.fcBgCard)
                .listRowSeparatorTint(Color.fcSeparator)
            }

            if !bajos.isEmpty {
                Section {
                    ForEach(bajos) { p in filaAlerta(p, nivel: .bajo) }
                } header: {
                    etiquetaSeccion("Stock bajo", icono: "arrow.down.circle.fill", color: .fcFg2)
                }
                .listRowBackground(Color.fcBgCard)
                .listRowSeparatorTint(Color.fcSeparator)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Subcomponentes

    private var resumenCabecera: some View {
        HStack(spacing: FCSpace.s4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(Color.fcWarning)
            VStack(alignment: .leading, spacing: FCSpace.s1) {
                Text("\(viewModel.productosStockBajo.count) producto\(viewModel.productosStockBajo.count == 1 ? "" : "s") con stock bajo")
                    .font(.headline)
                    .foregroundStyle(Color.fcBrandSoftFg)
                Text("Revisa y repón el inventario")
                    .font(.caption)
                    .foregroundStyle(Color.fcFg2)
            }
        }
        .padding(.vertical, FCSpace.s1)
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

    private var progreso: Double {
        guard producto.stockMinimo > 0 else { return 0 }
        return min(Double(producto.stock) / Double(producto.stockMinimo), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FCSpace.s2) {
            HStack {
                VStack(alignment: .leading, spacing: FCSpace.s1) {
                    Text(producto.nombreCompleto)
                        .font(.headline)
                        .foregroundStyle(Color.fcFg)
                    Text(producto.unidad ?? "Unidad")
                        .font(.caption)
                        .foregroundStyle(Color.fcFg2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: FCSpace.s1) {
                    Text("\(producto.stock)")
                        .font(.title3.bold())
                        .foregroundStyle(nivel.color)
                    Text("mín. \(producto.stockMinimo)")
                        .font(.caption2)
                        .foregroundStyle(Color.fcFg2)
                }
                .padding(.horizontal, FCSpace.s2)
                .padding(.vertical, FCSpace.s1)
                .background(nivel.bgColor)
                .clipShape(RoundedRectangle(cornerRadius: FCRadius.sm))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.fcSeparator)
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
        .padding(.vertical, FCSpace.s2)
    }
}

// MARK: - Niveles de alerta con tokens del sistema de diseño

private enum NivelAlerta {
    case agotado, critico, bajo

    var color: Color {
        switch self {
        case .agotado:        .fcDanger
        case .critico, .bajo: .fcWarning
        }
    }

    var bgColor: Color {
        switch self {
        case .agotado:        .fcDangerBg
        case .critico, .bajo: .fcWarningBg
        }
    }

    func descripcion(stock: Int32, minimo: Int32, unidad: String) -> String {
        if stock == 0 { return "Sin stock — reponer urgente" }
        return "Faltan \(minimo - stock) \(unidad.lowercased()) para alcanzar el mínimo"
    }
}
