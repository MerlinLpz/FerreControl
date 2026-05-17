// Raíz de la app: TabView con pestañas compartiendo un único ProductoViewModel
import SwiftUI
import CoreData

struct ContentView: View {

    /// ViewModel único compartido entre las dos pestañas para mantener estado sincronizado
    @StateObject private var viewModel: ProductoViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ProductoViewModel(context: context))
    }

    var body: some View {
        TabView {
            Tab("Resumen", systemImage: "chart.bar.fill") {
                DashboardView(viewModel: viewModel)
            }

            Tab("Inventario", systemImage: "list.bullet") {
                ProductoListView(viewModel: viewModel)
            }

            Tab("Alertas", systemImage: "exclamationmark.triangle.fill") {
                NavigationStack {
                    AlertasView(viewModel: viewModel)
                }
            }
            .badge(viewModel.productosStockBajo.count)
        }
    }
}

#Preview {
    ContentView(context: PersistenceController.preview.container.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
