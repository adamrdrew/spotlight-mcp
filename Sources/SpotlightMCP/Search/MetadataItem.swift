import Foundation
@preconcurrency import CoreServices

/// Errors that can occur when working with metadata items.
public enum MetadataError: Error, Equatable, Sendable {
    case invalidAttribute(String)
    case conversionFailed(String)
}

/// Wraps an MDItem for type-safe attribute extraction.
public struct MetadataItem {
    private let item: MDItem

    public init(item: MDItem) {
        self.item = item
    }

    public func getAttribute(_ key: String) -> MetadataValue? {
        extractValue(key)
    }

    public func getAllAttributes() -> [String: MetadataValue] {
        extractAllAttributes()
    }

    private func extractValue(_ key: String) -> MetadataValue? {
        guard let value = MDItemCopyAttribute(item, key as CFString) else {
            return nil
        }

        return convertToMetadataValue(value)
    }

    private func extractAllAttributes() -> [String: MetadataValue] {
        guard let names = getAttributeNames() else {
            return [:]
        }
        return buildAttributeDictionary(names)
    }

    private func getAttributeNames() -> [String]? {
        MDItemCopyAttributeNames(item) as? [String]
    }

    private func buildAttributeDictionary(_ names: [String]) -> [String: MetadataValue] {
        names.reduce(into: [:]) { result, key in
            if let value = extractValue(key) {
                result[key] = value
            }
        }
    }

    private func convertToMetadataValue(_ value: Any) -> MetadataValue? {
        convertValue(value)
    }

    private func convertValue(_ value: Any) -> MetadataValue? {
        if let simple = convertSimpleValue(value) {
            return simple
        }
        return convertComplexValue(value)
    }

    private func convertSimpleValue(_ value: Any) -> MetadataValue? {
        switch value {
        case let string as String:
            return .string(string)
        case let number as NSNumber:
            return convertNumber(number)
        default:
            return convertDate(value)
        }
    }

    private func convertDate(_ value: Any) -> MetadataValue? {
        guard let date = value as? Date else {
            return nil
        }
        return .date(date)
    }

    private func convertComplexValue(_ value: Any) -> MetadataValue? {
        switch value {
        case let array as [Any]:
            return convertArray(array)
        case let dict as [String: Any]:
            return convertDictionary(dict)
        default:
            return nil
        }
    }

    private func convertNumber(_ number: NSNumber) -> MetadataValue? {
        if CFNumberIsFloatType(number as CFNumber) {
            return .double(number.doubleValue)
        } else {
            return .int(number.intValue)
        }
    }

    private func convertArray(_ array: [Any]) -> MetadataValue? {
        let converted = array.compactMap(convertValue)
        return converted.count == array.count ? .array(converted) : nil
    }

    private func convertDictionary(_ dict: [String: Any]) -> MetadataValue? {
        let converted = dict.compactMapValues(convertValue)
        return converted.count == dict.count ? .dictionary(converted) : nil
    }
}
