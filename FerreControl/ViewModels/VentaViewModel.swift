// ViewModel para registrar ventas y descontar automáticamente del stock
import Foundation
import CoreData
import Combine

@MainActor
class VentaViewModel: ObservableObject {

    /// Mensaje de error para mostrar al usuario, nil si la operación fue exitosa
    @Published var errorMessage: String?

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Registra una venta y descuenta la cantidad del stock del producto
    func registrarVenta(producto: Producto, cantidad: Int32) {
        guard cantidad > 0 else {
            errorMessage = "La cantidad debe ser mayor a cero."
            return
        }
        guard cantidad <= producto.stock else {
            errorMessage = "Stock insuficiente. Disponible: \(producto.stock) \(producto.unidad ?? "unidades")."
            return
        }

        let venta = Venta(context: context)
        venta.cantidad = cantidad
        venta.fecha = Date()
        venta.producto = producto

        // Descuento inmediato en el inventario
        producto.stock -= cantidad

        do {
            try context.save()
        } catch {
            errorMessage = "Error al registrar la venta: \(error.localizedDescription)"
        }
    }
}
