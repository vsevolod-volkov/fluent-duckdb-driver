import FluentSQL
import SQLKit
import FluentKit

struct DuckDBConverterDelegate: SQLConverterDelegate {
    func customDataType(_ dataType: DatabaseSchema.DataType) -> (any SQLExpression)? {
        switch dataType {
        case .uuid:
            return SQLRaw("UUID")
        case .bool:
            return SQLRaw("BOOL")
        case .data:
            return SQLRaw("BYTEA")
        case .date:
            return SQLRaw("DATE")
        case .datetime:
            return SQLRaw("TIMESTAMPTZ")
        case .double:
            return SQLRaw("DOUBLE PRECISION")
        case .dictionary:
            return SQLRaw("JSONB")
        case .array(of: let type):
            if let type = type, let dataType = self.customDataType(type) {
                return SQLArrayDataType(dataType: dataType)
            } else {
                return SQLRaw("JSONB")
            }
        case .enum(let value):
            return SQLIdentifier(value.name)
        case .int8, .uint8:
            return SQLIdentifier("char")
        case .int16, .uint16:
            return SQLRaw("SMALLINT")
        case .int32, .uint32:
            return SQLRaw("INT")
        case .int64, .uint64:
            return SQLRaw("BIGINT")
        case .string:
            return SQLRaw("TEXT")
        case .time:
            return SQLRaw("TIME")
        case .float:
            return SQLRaw("FLOAT")
        case .custom:
            return nil
        }
    }
}

private struct SQLArrayDataType: SQLExpression {
    let dataType: any SQLExpression
    
    func serialize(to serializer: inout SQLSerializer) {
        self.dataType.serialize(to: &serializer)
        serializer.write("[]")
    }
}
