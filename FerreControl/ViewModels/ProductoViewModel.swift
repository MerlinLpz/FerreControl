// ViewModel principal: gestiona el CRUD completo de productos y alertas de stock bajo
import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class ProductoViewModel: ObservableObject {

    /// Lista completa de productos cargados desde CoreData
    @Published var productos: [Producto] = []

    /// Texto ingresado en la barra de búsqueda
    @Published var busqueda: String = ""

    /// Mensaje de error para mostrar al usuario, nil si no hay error
    @Published var errorMessage: String?

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        cargarProductos()
    }

    // MARK: - Propiedades computadas

    /// Filtra por nombre, medida o unidad según el texto de búsqueda
    var productosFiltrados: [Producto] {
        guard !busqueda.isEmpty else { return productos }
        return productos.filter {
            $0.nombreCompleto.localizedCaseInsensitiveContains(busqueda) ||
            ($0.unidad ?? "").localizedCaseInsensitiveContains(busqueda)
        }
    }

    /// Productos cuyo stock llegó al mínimo — se usan para mostrar la alerta
    var productosStockBajo: [Producto] {
        productos.filter { $0.stockBajo }
    }

    // MARK: - Estadísticas para el Dashboard

    /// Valor total del inventario: suma de (stock × precio) por producto
    var valorTotalInventario: Double {
        productos.reduce(0.0) { $0 + Double($1.stock) * $1.precio }
    }

    /// Total de unidades vendidas en toda la historia
    var totalUnidadesVendidas: Int32 {
        productos.reduce(Int32(0)) { $0 + $1.totalVendido }
    }

    /// Producto con mayor cantidad total vendida
    var productoMasVendido: Producto? {
        productos.filter { $0.totalVendido > 0 }.max { $0.totalVendido < $1.totalVendido }
    }

    /// Últimas 5 ventas de todos los productos, ordenadas de más reciente a más antigua
    var ventasRecientes: [Venta] {
        let todas = productos.flatMap { $0.ventasArray }
        let ordenadas = todas.sorted { ($0.fecha ?? .distantPast) > ($1.fecha ?? .distantPast) }
        return Array(ordenadas.prefix(5))
    }

    // MARK: - CRUD

    func cargarProductos() {
        let request = Producto.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Producto.nombre, ascending: true)
        ]
        do {
            productos = try context.fetch(request)
        } catch {
            errorMessage = "Error al cargar productos: \(error.localizedDescription)"
        }
    }

    func agregarProducto(nombre: String, medida: String, unidad: String,
                         stock: Int32, stockMinimo: Int32, precio: Double) {
        let producto = Producto(context: context)
        producto.nombre = nombre.trimmingCharacters(in: .whitespaces)
        producto.medida = medida.trimmingCharacters(in: .whitespaces)
        producto.unidad = unidad
        producto.stock = stock
        producto.stockMinimo = stockMinimo
        producto.precio = precio
        guardar()
    }

    func actualizarProducto(_ producto: Producto, nombre: String, medida: String,
                            unidad: String, stock: Int32, stockMinimo: Int32, precio: Double) {
        producto.nombre = nombre.trimmingCharacters(in: .whitespaces)
        producto.medida = medida.trimmingCharacters(in: .whitespaces)
        producto.unidad = unidad
        producto.stock = stock
        producto.stockMinimo = stockMinimo
        producto.precio = precio
        guardar()
    }

    func eliminarProductos(en offsets: IndexSet, de lista: [Producto]) {
        offsets.map { lista[$0] }.forEach(context.delete)
        guardar()
    }

    // MARK: - Persistencia

    func guardar() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            cargarProductos()
        } catch {
            errorMessage = "Error al guardar: \(error.localizedDescription)"
        }
    }
}
