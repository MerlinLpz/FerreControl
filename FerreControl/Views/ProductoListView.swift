// Vista principal: lista de productos con búsqueda y navegación al detalle
import SwiftUI
import CoreData

struct ProductoListView: View {

    @ObservedObject var viewModel: ProductoViewModel
    @State private var mostrarFormulario = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.productosFiltrados.isEmpty {
                    contenidoVacio
                } else {
                    listaProductos
                }
            }
            .navigationTitle("Inventario")
            .searchable(text: $viewModel.busqueda, prompt: "Buscar producto...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        mostrarFormulario = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
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

    // MARK: - Subvistas

    private var listaProductos: some View {
        List {
            ForEach(viewModel.productosFiltrados) { producto in
                NavigationLink(destination: ProductoDetailView(producto: producto, viewModel: viewModel)) {
                    FilaProducto(producto: producto)
                }
            }
            .onDelete { offsets in
                viewModel.eliminarProductos(en: offsets, de: viewModel.productosFiltrados)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var contenidoVacio: some View {
        VStack(spacing: 16) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text(viewModel.busqueda.isEmpty ? "Sin productos" : "Sin resultados")
                .font(.title3)
                .foregroundStyle(.secondary)
            if viewModel.busqueda.isEmpty {
                Text("Toca el botón + para agregar tu primer producto")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

// MARK: - Fila individual del producto

private struct FilaProducto: View {
    let producto: Producto

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(producto.nombreCompleto)
                    .font(.headline)
                HStack(spacing: 4) {
                    Text(producto.unidad ?? "Unidad")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(producto.precio.enSoles)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(producto.stock)")
                    .font(.title3.bold())
                    .foregroundStyle(producto.stockBajo ? .red : .primary)
                Text("en stock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
