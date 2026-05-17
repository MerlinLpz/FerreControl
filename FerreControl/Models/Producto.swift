// Modelo CoreData que representa un artículo del inventario de la ferretería
import Foundation
import CoreData

@objc(Producto)
public class Producto: NSManagedObject {}

extension Producto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Producto> {
        return NSFetchRequest<Producto>(entityName: "Producto")
    }

    /// Nombre del producto (ej: "Tornillo", "Tubería")
    @NSManaged public var nombre: String?

    /// Medida específica (ej: "1/2 pulgada", "3/4 pulgada")
    @NSManaged public var medida: String?

    /// Unidad de venta (ej: "Unidad", "Bolsa", "Metro")
    @NSManaged public var unidad: String?

    /// Cantidad disponible en almacén
    @NSManaged public var stock: Int32

    /// Cantidad mínima antes de generar alerta de reposición
    @NSManaged public var stockMinimo: Int32

    /// Precio de venta en soles (S/)
    @NSManaged public var precio: Double

    /// Historial de ventas asociadas a este producto
    @NSManaged public var ventas: NSSet?
}

extension Producto: Identifiable {

    /// Nombre completo para mostrar: "Tornillo 1/2 pulgada"
    var nombreCompleto: String {
        let base = nombre ?? "Sin nombre"
        guard let med = medida, !med.isEmpty else { return base }
        return "\(base) \(med)"
    }

    /// true cuando el stock actual es igual o menor al stock mínimo
    var stockBajo: Bool {
        stock <= stockMinimo
    }

    /// Array de ventas ordenado de más reciente a más antiguo
    var ventasArray: [Venta] {
        let set = ventas as? Set<Venta> ?? []
        return set.sorted { ($0.fecha ?? .distantPast) > ($1.fecha ?? .distantPast) }
    }

    /// Total de unidades vendidas en todo el historial
    var totalVendido: Int32 {
        ventasArray.reduce(0) { $0 + $1.cantidad }
    }
}

// Métodos generados para manejar la relación to-many con Venta
extension Producto {

    @objc(addVentasObject:)
    @NSManaged public func addToVentas(_ value: Venta)

    @objc(removeVentasObject:)
    @NSManaged public func removeFromVentas(_ value: Venta)

    @objc(addVentas:)
    @NSManaged public func addToVentas(_ values: NSSet)

    @objc(removeVentas:)
    @NSManaged public func removeFromVentas(_ values: NSSet)
}
