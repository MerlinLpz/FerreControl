// Modelo CoreData que registra cada operación de salida de inventario
import Foundation
import CoreData

@objc(Venta)
public class Venta: NSManagedObject {}

extension Venta {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venta> {
        return NSFetchRequest<Venta>(entityName: "Venta")
    }

    /// Cantidad de unidades vendidas en esta operación
    @NSManaged public var cantidad: Int32

    /// Fecha y hora en que se registró la venta
    @NSManaged public var fecha: Date?

    /// Producto al que pertenece esta venta
    @NSManaged public var producto: Producto?
}

extension Venta: Identifiable {}
