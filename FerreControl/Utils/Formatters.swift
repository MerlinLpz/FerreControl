// Formateadores reutilizables para moneda (soles peruanos) y fechas
import Foundation

extension Double {
    /// Formatea el valor como precio en soles peruanos: "S/ 12.50"
    var enSoles: String {
        Formatters.moneda.string(from: NSNumber(value: self)) ?? "S/ 0.00"
    }
}

extension Date {
    /// Fecha corta: "17/05/2026"
    var corta: String {
        Formatters.fechaCorta.string(from: self)
    }

    /// Fecha con hora: "17/05/2026, 10:30"
    var conHora: String {
        Formatters.fechaConHora.string(from: self)
    }
}

enum Formatters {

    static let moneda: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "PEN"
        f.currencySymbol = "S/"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "es_PE")
        return f
    }()

    static let fechaCorta: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        f.locale = Locale(identifier: "es_PE")
        return f
    }()

    static let fechaConHora: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_PE")
        return f
    }()
}

/// Unidades de medida más comunes en una ferretería peruana
enum UnidadMedida: String, CaseIterable {
    case unidad = "Unidad"
    case bolsa = "Bolsa"
    case caja = "Caja"
    case metro = "Metro"
    case kilo = "Kilo"
    case litro = "Litro"
    case par = "Par"
    case docena = "Docena"
    case rollo = "Rollo"
    case plancha = "Plancha"
}
