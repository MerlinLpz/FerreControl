// Controlador de CoreData: configura el contenedor persistente y datos de previsualización
import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    /// Contexto en memoria para SwiftUI Previews — no persiste datos al disco
    @MainActor
    static let preview: PersistenceController = {
        let controlador = PersistenceController(inMemory: true)
        let ctx = controlador.container.viewContext

        // Datos de muestra para las previsualizaciones de SwiftUI
        let ejemplos: [(nombre: String, medida: String, unidad: String, stock: Int32, stockMin: Int32, precio: Double)] = [
            ("Tornillo", "1/2 pulgada", "Bolsa",   150, 20,  2.50),
            ("Tubería",  "3/4 pulgada", "Metro",    30,  10, 12.00),
            ("Pintura",  "Blanca 4L",   "Unidad",    8,  5,  45.00),
            ("Clavo",    "2 pulgadas",  "Kilo",     200, 50,  4.80),
            ("Llave",    "10mm",        "Unidad",     3,  5,  18.50)
        ]

        for ej in ejemplos {
            let producto = Producto(context: ctx)
            producto.nombre     = ej.nombre
            producto.medida     = ej.medida
            producto.unidad     = ej.unidad
            producto.stock      = ej.stock
            producto.stockMinimo = ej.stockMin
            producto.precio     = ej.precio

            // Agregar algunas ventas de ejemplo al primer producto
            if ej.nombre == "Tornillo" {
                for i in 1...3 {
                    let venta = Venta(context: ctx)
                    venta.cantidad = Int32(i * 5)
                    venta.fecha = Calendar.current.date(byAdding: .day, value: -i, to: Date())
                    venta.producto = producto
                }
            }
        }

        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            fatalError("Error al guardar datos de previsualización: \(nsError), \(nsError.userInfo)")
        }
        return controlador
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FerreControl")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error al cargar el almacén persistente: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
