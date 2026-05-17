// Vista principal: inventario con FAB terracota y badges semánticos de stock
import SwiftUI
import CoreData

struct ProductoListView: View {

    @ObservedObject var viewModel: ProductoViewModel
    @State private var mostrarFormulario = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if viewModel.productosFiltrados.isEmpty {
                        contenidoVacio
                    } else {
                        listaProductos
                    }
                }

                fabAgregarProducto
                    .padding(.trailing, FCSpace.s5)
                    .padding(.bottom, FCSpace.s5)
            }
            .navigationTitle("Inventario")
            .searchable(text: $viewModel.busqueda, prompt: "Buscar producto...")
            .background(Color.fcBgApp)
            .toolbarBackground(Color.fcBgApp, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $mostrarFormulario) {
                ProductoFormView(viewModel: viewModel)
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

    // MARK: - FAB circular terracota

    private var fabAgregarProducto: some View {
        Button { mostrarFormulario = true } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.fcBrand)
                .clipShape(Circle())
                .shadow(color: Color.fcBrand.opacity(0.45), radius: 12, x: 0, y: 5)
        }
    }

    // MARK: - Lista

    private var listaProductos: some View {
        List {
            ForEach(viewModel.productosFiltrados) { producto in
                NavigationLink(destination: ProductoDetailView(producto: producto, viewModel: viewModel)) {
                    FilaProducto(producto: producto)
                }
                .listRowBackground(Color.fcBgCard)
                .listRowSeparatorTint(Color.fcSeparator)
            }
            .onDelete { offsets in
                viewModel.eliminarProductos(en: offsets, de: viewModel.productosFiltrados)
            }

            // Espacio para que el FAB no tape el último elemento
            Color.clear
                .frame(height: 80)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Estado vacío

    private var contenidoVacio: some View {
        VStack(spacing: FCSpace.s4) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(Color.fcFg3)
            Text(viewModel.busqueda.isEmpty ? "Sin productos" : "Sin resultados")
                .font(.title3)
                .foregroundStyle(Color.fcFg2)
            if viewModel.busqueda.isEmpty {
                Text("Toca el botón + para agregar tu primer producto")
                    .font(.caption)
                    .foregroundStyle(Color.fcFg3)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Fila de producto con badge semántico de stock

private struct FilaProducto: View {
    let producto: Producto

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

    var body: some View {
        HStack(spacing: FCSpace.s3) {
            VStack(alignment: .leading, spacing: FCSpace.s1) {
                Text(producto.nombreCompleto)
                    .font(.headline)
                    .foregroundStyle(Color.fcFg)
                HStack(spacing: FCSpace.s1) {
                    Text(producto.unidad ?? "Unidad")
                        .font(.caption)
                        .foregroundStyle(Color.fcFg3)
                    Text("·")
                        .foregroundStyle(Color.fcFg3)
                    Text(producto.precio.enSoles)
                        .font(.caption)
                        .foregroundStyle(Color.fcFg3)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(producto.stock)")
                    .font(.title3.bold())
                    .foregroundStyle(stockFg)
                Text("en stock")
                    .font(.caption2)
                    .foregroundStyle(stockFg)
            }
            .padding(.horizontal, FCSpace.s2)
            .padding(.vertical, FCSpace.s1)
            .background(stockBg)
            .clipShape(RoundedRectangle(cornerRadius: FCRadius.sm))
        }
        .padding(.vertical, FCSpace.s2)
    }
}
