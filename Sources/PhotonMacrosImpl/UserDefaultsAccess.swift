import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct UserDefaultsAccessMacro: AccessorMacro {
    public static func expansion<Context: SwiftSyntaxMacros.MacroExpansionContext, DeclSyntax: SwiftSyntax.DeclSyntaxProtocol>(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: DeclSyntax,
        in context: Context
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            context.diagnose(.init(node: node, message: SyntaxParseError()))
            return []
        }
        
        guard let defaultValue = arguments.first(where: { syntax in
            syntax.label?.text == "defaultValue"
        }) else {
            context.diagnose(.init(node: node, message: SyntaxParseError()))
            return []
        }
        
        let defaultValueExpression = defaultValue.expression
        let defaultValueDescription = defaultValueExpression.description
        
        let propertyTypeExpression: String
        if let _ = defaultValueExpression.as(BooleanLiteralExprSyntax.self) {
            propertyTypeExpression = "Bool"
        } else if let _ = defaultValueExpression.as(IntegerLiteralExprSyntax.self) {
            propertyTypeExpression = "Int"
        } else if let _ = defaultValueExpression.as(StringLiteralExprSyntax.self) {
            propertyTypeExpression = "String"
        } else if let _ = defaultValueExpression.as(FloatLiteralExprSyntax.self) {
            propertyTypeExpression = "Float"
        } else {
            if let memberAccess = defaultValueExpression.as(MemberAccessExprSyntax.self),
               let base = memberAccess.base?.as(DeclReferenceExprSyntax.self) {
                propertyTypeExpression = base.baseName.text
            } else {
                context.diagnose(.init(node: node, message: UnsupportedTypeError(extraMessage: "propertyTypeExpression is \(defaultValueExpression)")))
                return []
            }
        }
        
        let storeExpression: String
        if let storeValue = (arguments.first { syntax in
            syntax.label?.text == "store"
        }) {
            storeExpression = storeValue.expression.description
        } else {
            storeExpression = "UserDefaults.standard"
        }
        
        guard let declationSyntax = declaration.as(VariableDeclSyntax.self)?.bindings else {
            context.diagnose(.init(node: node, message: SyntaxParseError()))
            return []
        }
        guard let firstBindingSyntax = declationSyntax.first?.as(PatternBindingSyntax.self)?.pattern.as(IdentifierPatternSyntax.self) else {
            context.diagnose(.init(node: node, message: SyntaxParseError()))
            return []
        }
        
        let keySyntax = arguments.first { syntax in
            syntax.label?.text == "key"
        }
        
        let storeKeyValue: String?
        
        if let keySyntax = keySyntax {
            storeKeyValue = keySyntax.expression.description
        } else {
            storeKeyValue = "\"\(firstBindingSyntax.identifier.text)\""
        }
        
        guard let storeKeyValue: String = storeKeyValue else {
            context.diagnose(.init(node: node, message: SyntaxParseError()))
            return []
        }
        
        let getExpression: AccessorDeclSyntax
        let setExpression: AccessorDeclSyntax = """
            \(raw: storeExpression).setValue(newValue, forKey: \(raw: storeKeyValue))
            """
        
        if propertyTypeExpression == "Bool" {
            getExpression = """
            \(raw: storeExpression).bool(forKey: \(raw: storeKeyValue))
            """
        } else if propertyTypeExpression == "Int" {
            getExpression = """
            \(raw: storeExpression).integer(forKey: \(raw: storeKeyValue))
            """
        } else if propertyTypeExpression == "String" {
            getExpression = """
            \(raw: storeExpression).string(forKey: \(raw: storeKeyValue)) ?? \(raw: defaultValueDescription)
            """
        } else if propertyTypeExpression == "Float" {
            getExpression = """
            \(raw: storeExpression).float(forKey: \(raw: storeKeyValue))
            """
        } else {
            context.diagnose(.init(node: node, message: UnsupportedTypeError()))
            return []
        }
                       
        return [
            """
            get {
                if \(raw: storeExpression).value(forKey: \(raw: storeKeyValue)) == nil {
                    return \(raw: defaultValueDescription)
                }
                return \(getExpression)
            }
            set {
                \(setExpression)
            }
            """
        ]
    }
}

struct UnsupportedTypeError: DiagnosticMessage, Error {
    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "com.juniperphoton.macros", id: message)
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity = .error
    
    let message: String = "Unsupported type. Supported types are: String, Int, Bool, Float."
    let extraMessage: String
    
    init(extraMessage: String = "") {
        self.extraMessage = extraMessage
    }
}

struct SyntaxParseError: DiagnosticMessage, Error {
    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "com.juniperphoton.macros", id: message)
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity = .error
    
    let message: String = "Can't parse this syntax"
}

struct MacroError: DiagnosticMessage, Error {
    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "com.juniperphoton.macros", id: message)
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity = .error
    
    let message: String
}

@main
struct PhotonMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UserDefaultsAccessMacro.self
    ]
}
