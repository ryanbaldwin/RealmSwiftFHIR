//
//  DomainResource.swift
//  SwiftFHIR
//
//  Generated from FHIR 1.0.2.7202 (http://hl7.org/fhir/StructureDefinition/DomainResource) on 2017-11-13.
//  2017, SMART Health IT.
//
// 	Updated for Realm support by Ryan Baldwin on 2017-11-13
// 	Copyright @ 2017 Bunnyhug. All rights fall under Apache 2

import Foundation
import Realm
import RealmSwift


/**
 *  A resource with narrative, extensions, and contained resources.
 *
 *  A resource that includes narrative, extensions, and contained resources.
 */
open class DomainResource: Resource {
	override open class var resourceType: String {
		get { return "DomainResource" }
	}

    public let contained = RealmSwift.List<ContainedResource>()
    public let extension_fhir = RealmSwift.List<Extension>()
    public let modifierExtension = RealmSwift.List<Extension>()
    @objc public dynamic var text: Narrative?
    public func upsert(text: Narrative?) {
        upsert(prop: &self.text, val: text)
    }

    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case contained = "contained"
        case extension_fhir = "extension"
        case modifierExtension = "modifierExtension"
        case text = "text"
    }
    
    public required init() {
      super.init()
    }

    public required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.contained) {
            // Need to loop through all the contained items twice.
            // First time through we grab the resource type
            // the second time through we decode the contained resource for the actual resource type
            // I cannot find a better way to do this in Apple's Decodable containers.
            // If there's a way to get at the raw data in a container without decoding it,
            // please let me know and I will buy you 🍻
            var inflatedContainers: [ContainedResource] = []
            var containedList = try container.nestedUnkeyedContainer(forKey: .contained)
            //print("Inflating \(containedList.count ?? 0) items.")
            while !containedList.isAtEnd {
                inflatedContainers.append(try containedList.decode(ContainedResource.self))
            }
            
            var secondPass = try container.nestedUnkeyedContainer(forKey: .contained)
            while !secondPass.isAtEnd {
                let containedResource = inflatedContainers[secondPass.currentIndex]
                let actualResource = try secondPass.decodeFHIRAbstractBase(containedResource.resourceType!)
                containedResource.json = try JSONEncoder().encode(actualResource)
            }
            
            self.contained.append(objectsIn: inflatedContainers)
        }
        self.extension_fhir.append(objectsIn: try container.decodeIfPresent([Extension].self, forKey: .extension_fhir) ?? [])
        self.modifierExtension.append(objectsIn: try container.decodeIfPresent([Extension].self, forKey: .modifierExtension) ?? [])
        self.text = try container.decodeIfPresent(Narrative.self, forKey: .text)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        let containedItems = Array(self.contained.flatMap { $0.resource })
        try container.encode(containedItems, forKey: .contained)
        try container.encode(Array(self.extension_fhir), forKey: .extension_fhir)
        try container.encode(Array(self.modifierExtension), forKey: .modifierExtension)
        try container.encodeIfPresent(self.text, forKey: .text)
    }

	public override func copy(with zone: NSZone? = nil) -> Any {
		do {
			let data = try JSONEncoder().encode(self)
			let clone = try JSONDecoder().decode(DomainResource.self, from: data)
			return clone
		} catch let error {
			print("Failed to copy DomainResource. Will return empty instance: \(error))")
		}
		return DomainResource.init()
	}

    public override func populate(from other: Any) {
        guard let o = other as? DomainResource else {
            print("Tried to populate \(Swift.type(of: self)) with values from \(Swift.type(of: other)). Skipping.")
            return
        }
        
        super.populate(from: o)

        for (index, t) in o.contained.enumerated() {
            guard index < self.contained.count else {
                // we should always copy in case the same source is being used across several targets
                // in a single transaction.
                let val = ContainedResource()
                val.populate(from: t)
                self.contained.append(val)
                continue
            }
            self.contained[index].populate(from: t)
        }
    
        while self.contained.count > o.contained.count {
            let objectToRemove = self.contained.last!
            self.contained.removeLast()
            try! (objectToRemove as? CascadeDeletable)?.cascadeDelete() ?? realm?.delete(objectToRemove)
        }

        for (index, t) in o.extension_fhir.enumerated() {
            guard index < self.extension_fhir.count else {
                // we should always copy in case the same source is being used across several targets
                // in a single transaction.
                let val = Extension()
                val.populate(from: t)
                self.extension_fhir.append(val)
                continue
            }
            self.extension_fhir[index].populate(from: t)
        }
    
        while self.extension_fhir.count > o.extension_fhir.count {
            let objectToRemove = self.extension_fhir.last!
            self.extension_fhir.removeLast()
            try! (objectToRemove as? CascadeDeletable)?.cascadeDelete() ?? realm?.delete(objectToRemove)
        }

        for (index, t) in o.modifierExtension.enumerated() {
            guard index < self.modifierExtension.count else {
                // we should always copy in case the same source is being used across several targets
                // in a single transaction.
                let val = Extension()
                val.populate(from: t)
                self.modifierExtension.append(val)
                continue
            }
            self.modifierExtension[index].populate(from: t)
        }
    
        while self.modifierExtension.count > o.modifierExtension.count {
            let objectToRemove = self.modifierExtension.last!
            self.modifierExtension.removeLast()
            try! (objectToRemove as? CascadeDeletable)?.cascadeDelete() ?? realm?.delete(objectToRemove)
        }
        FireKit.populate(&self.text, from: o.text)
    }
}

