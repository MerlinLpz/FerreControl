// Vista de detalle: información, historial y gráfico de ventas con paleta terracota
import SwiftUI
import Charts

struct ProductoDetailView: View {

    @ObservedObject var producto: Producto
    @ObservedObject var viewModel: ProductoViewModel

    @State private var mostrarEdicion = false
    @State private var mostrarVenta = false

    var body: some View {
        List {
            seccionInfo
            seccionVentas
            seccionGrafico
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.fcBgApp)
        .navigationTitle(producto.nombreCompleto)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.fcBgApp, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Color.fcBrand)
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

    // MARK: - Colores semánticos del stock

    private var stockFg: Color {
        if producto.stock == 0 { return .fcDanger }
        if producto.stockBajo   { return .fcWarning }
        return .fcSuccess
    }

    private var stockBg: Color {
        if producto.stock == 0 { return .fcDangerBg }
        if producto.stockBajo   { return .fcWarningBg }
        return .fcSuccessBg
    }

    private var stockIcono: String {
        if producto.stock == 0 { return "xmark.circle.fill" }
        if producto.stockBajo   { return "exclamationmark.triangle.fill" }
        return "checkmark.circle.fill"
    }

    // MARK: - Secciones

    private var seccionInfo: some View {
        Section("Información") {
            FilaDetalle(icono: "tag",           etiqueta: "Medida",  valor: producto.medida ?? "—")
            FilaDetalle(icono: "square.grid.2x2", etiqueta: "Unidad", valor: producto.unidad ?? "—")
            FilaDetalle(icono: "peruniansol",   etiqueta: "Precio",  valor: producto.precio.enSoles)

            HStack {
                Label("Stock actual", systemImage: "archivebox")
                    .foregroundStyle(Color.fcFg)
                Spacer()
                HStack(spacing: FCSpace.s1) {
                    Text("\(producto.stock)")
                        .bold()
                    Image(systemName: stockIcono)
                }
                .foregroundStyle(stockFg)
                .padding(.horizontal, FCSpace.s2)
                .padding(.vertical, FCSpace.s1)
                .background(stockBg)
                .clipShape(RoundedRectangle(cornerRadius: FCRadius.sm))
            }

            FilaDetalle(icono: "arrow.down.to.line", etiqueta: "Stock mínimo",
                        valor: "\(producto.stockMinimo)")
            FilaDetalle(icono: "cart", etiqueta: "Total vendido",
                        valor: "\(producto.totalVendido) \(producto.unidad ?? "unidades")")

            Button {
                mostrarVenta = true
            } label: {
                Label("Registrar venta", systemImage: "minus.circle")
                    .foregroundStyle(producto.stock > 0 ? Color.fcBrand : Color.fcFg3)
            }
            .disabled(producto.stock == 0)
        }
        .listRowBackground(Color.fcBgCard)
        .listRowSeparatorTint(Color.fcSeparator)
    }

    private var seccionVentas: some View {
        Section("Historial de ventas (\(producto.ventasArray.count))") {
            if producto.ventasArray.isEmpty {
                Text("Sin ventas registradas")
                    .foregroundStyle(Color.fcFg3)
                    .italic()
            } else {
                ForEach(producto.ventasArray) { venta in
                    FilaVenta(venta: venta, unidad: producto.unidad ?? "")
                }
            }
        }
        .listRowBackground(Color.fcBgCard)
        .listRowSeparatorTint(Color.fcSeparator)
    }

    // MARK: - Gráfico de ventas por día

    private var ventasPorDia: [DatoVenta] {
        let cal = Calendar.current
        let agrupadas = Dictionary(grouping: producto.ventasArray) { venta in
            cal.startOfDay(for: venta.fecha ?? Date())
        }
        return agrupadas
            .map { DatoVenta(dia: $0.key, total: $0.value.reduce(Int32(0)) { $0 + $1.cantidad }) }
            .sorted { $0.dia < $1.dia }
    }

    private var seccionGrafico: some View {
        Section("Ventas por día") {
            if ventasPorDia.isEmpty {
                VStack(spacing: FCSpace.s3) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.fcBrand.opacity(0.3))
                    Text("Sin datos para graficar")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.fcFg2)
                    Text("Registra la primera venta y el gráfico\naparecerá aquí automáticamente.")
                        .font(.caption)
                        .foregroundStyle(Color.fcFg3)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else {
                Chart(ventasPorDia) { dato in
                    BarMark(
                        x: .value("Día", dato.dia, unit: .day),
                        y: .value(producto.unidad ?? "Unidades", dato.total)
                    )
                    .foregroundStyle(Color.fcBrand.gradient)
                    .cornerRadius(6)
                    .annotation(position: .top, alignment: .center) {
                        Text("\(dato.total)")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.fcBrand)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.fcSeparator)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day(),
                                       centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.fcSeparator)
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: 0...(ventasPorDia.map(\.total).max().map { Int($0) + 2 } ?? 10))
                .frame(height: 200)
                .padding(.vertical, FCSpace.s3)
            }
        }
        .listRowBackground(Color.fcBgCard)
    }
}

// MARK: - Helpers

private struct DatoVenta: Identifiable {
    let id = UUID()
    let dia: Date
    let total: Int32
}

private struct FilaDetalle: View {
    let icono: String
    let etiqueta: String
    let valor: String

    var body: some View {
        Label {
            HStack {
                Text(etiqueta).foregroundStyle(Color.fcFg)
                Spacer()
                Text(valor).foregroundStyle(Color.fcFg2)
            }
        } icon: {
            Image(systemName: icono).foregroundStyle(Color.fcBrand)
        }
    }
}

private struct FilaVenta: View {
    let venta: Venta
    let unidad: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(venta.fecha?.corta ?? "Fecha desconocida")
                    .font(.subheadline)
                    .foregroundStyle(Color.fcFg)
                Text(venta.fecha?.conHora ?? "")
                    .font(.caption)
                    .foregroundStyle(Color.fcFg3)
            }
            Spacer()
            Text("-\(venta.cantidad) \(unidad.lowercased())")
                .font(.subheadline.bold())
                .foregroundStyle(Color.fcDanger)
        }
    }
}
