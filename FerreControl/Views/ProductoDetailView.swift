// Vista de detalle: información del producto e historial de ventas
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

    // MARK: - Gráfico de ventas por día

    /// Agrupa las ventas del producto por día calendario y suma las cantidades
    private var ventasPorDia: [DatoVenta] {
        let calendario = Calendar.current
        let agrupadas = Dictionary(grouping: producto.ventasArray) { venta in
            calendario.startOfDay(for: venta.fecha ?? Date())
        }
        return agrupadas
            .map { DatoVenta(dia: $0.key, total: $0.value.reduce(Int32(0)) { $0 + $1.cantidad }) }
            .sorted { $0.dia < $1.dia }
    }

    private var seccionGrafico: some View {
        Section("Ventas por día") {
            if ventasPorDia.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 44))
                        .foregroundStyle(.purple.opacity(0.35))
                    Text("Sin datos para graficar")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    Text("Registra la primera venta y el gráfico\naparecerá aquí automáticamente.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
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
                    .foregroundStyle(Color.purple.gradient)
                    .cornerRadius(6)
                    .annotation(position: .top, alignment: .center) {
                        Text("\(dato.total)")
                            .font(.caption2.bold())
                            .foregroundStyle(.purple)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color(.systemGray4))
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day(),
                                       centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color(.systemGray4))
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: 0...(ventasPorDia.map(\.total).max().map { Int($0) + 2 } ?? 10))
                .frame(height: 200)
                .padding(.vertical, 12)
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

// MARK: - Dato del gráfico: ventas agrupadas por día

private struct DatoVenta: Identifiable {
    let id = UUID()
    let dia: Date
    let total: Int32
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
