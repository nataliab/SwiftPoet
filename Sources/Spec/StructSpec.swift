//
//  StructSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class StructSpec: TypeSpecImpl {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Mutating, .Throws]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: StructSpecBuilder) {
        super.init(builder: b as TypeSpecBuilderImpl)
    }

    public static func builder(name: String) -> StructSpecBuilder {
        return StructSpecBuilder(name: name)
    }
}

public class StructSpecBuilder: TypeSpecBuilderImpl, Builder {
    public typealias Result = StructSpec
    public static let defaultConstruct: Construct = .Struct
    private var includeInit: Bool = false

    public init(name: String) {
        super.init(name: name, construct: StructSpecBuilder.defaultConstruct, methodSpecs: [MethodSpec](), fieldSpecs: [FieldSpec](), superProtocols: [TypeName]())
    }

    public func build() -> Result {
        if !(methodSpecs!.contains { $0.name == "init" }) || includeInit {
            addInitMethod()
        }
        return StructSpec(b: self)
    }

    private func addInitMethod() {
        if methodSpecs == nil || methodSpecs!.count == 0 {
            let mb = MethodSpec.builder("init")
            let cb = CodeBlock.builder()

            self.fieldSpecs?.forEach { spec in
                if Modifier.equivalentAccessLevel(parentModifiers: self.modifiers, childModifiers: spec.modifiers) {
                    mb.addParameter(ParameterSpec.builder(spec.name, type: spec.type!)
                        .addModifiers(Array(spec.modifiers))
                        .addDescription(spec.description)
                        .build()
                    )

                    cb.addCodeBlock(CodeBlock.builder()
                        .addEmitObject(.Literal, any: "self.\(spec.name) = \(spec.name)")
                        .build()
                    )
                }
            }

            mb.addCode(cb.build())

            self.addMethodSpec(mb.build())
        }
    }

    public func includeDefaultInit() -> StructSpecBuilder {
        includeInit = true
        return self;
    }
}

// MARK: Chaining
extension StructSpecBuilder {

    public func addMethodSpecs(methodSpecList: [MethodSpec]) -> Self {
        methodSpecList.forEach { self.addMethodSpec($0) }
        return self
    }

    public func addMethodSpec(methodSpec: MethodSpec) -> Self {
        super.addMethodSpec(methodSpec: methodSpec)
        methodSpec.parentType = self.construct
        return self
    }

    public func addFieldSpec(fieldSpec: FieldSpec) -> Self {
        super.addFieldSpec(fieldSpec)
        fieldSpec.parentType = .Enum
        return self
    }

    public func addFieldSpecs(fieldSpecList: [FieldSpec]) -> Self {
        fieldSpecList.forEach { addFieldSpec($0) }
        return self
    }

    public func addProtocol(protocolSpec: TypeName) -> Self {
        super.addProtocol(protocolSpec)
        return self
    }

    public func addProtocols(protocolList: [TypeName]) -> Self {
        super.addProtocols(protocolList)
        return self
    }

    public func addSuperType(superClass: TypeName) -> Self {
        super.addSuperType(superClass)
        return self
    }

    public func addModifier(m: Modifier) -> Self {
        guard (StructSpec.asMemberModifiers.filter { $0 == m }).count == 1 else {
            return self
        }
        super.addModifier(internalMethod: m)
        return self
    }

    public func addModifiers(modifiers mList: [Modifier]) -> Self {
        mList.forEach { addModifier($0) }
        return self
    }

    public func addDescription(description: String?) -> Self {
        super.addDescription(description)
        return self
    }
}