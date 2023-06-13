

import Foundation
import ObjectMapper

protocol ILocalService {
    func save<T>(_ value: T, forKey key: String, userOnly: Bool)
    func get<T>(forKey key: String, userOnly: Bool) -> T?

    func saveModel<T: SFModel>(_ model: T?, forKey key: String, userOnly: Bool)
    func loadModel<T: SFModel>(forKey key: String, userOnly: Bool) -> T?

    func saveModels<T: SFModel>(_ models: [T]?, forKey key: String, userOnly: Bool)
    func loadModels<T: SFModel>(forKey key: String, userOnly: Bool) -> [T]?

    func remove(_ key: String, userOnly: Bool)
}

class SFLocalService: NSObject, ILocalService {

    @objc static let shared = SFLocalService()
    private let defaults = UserDefaults.standard

    /// Save generic type to UserDefaults
    func save<T>(_ value: T, forKey key: String, userOnly: Bool = false) {
        defaults.set(value, forKey: combine(key, userOnly: userOnly))
        defaults.synchronize()
    }

    /// Get generic type from UserDefaults
    func get<T>(forKey key: String, userOnly: Bool = false) -> T? {
        return defaults.value(forKey: combine(key, userOnly: userOnly)) as? T
    }

    /// Save model to UserDefaults
    func saveModel<T: SFModel>(_ model: T?, forKey key: String, userOnly: Bool) {
        if let model = model {
            let json = model.toJSON()
            defaults.set(json, forKey: combine(key, userOnly: userOnly))
            defaults.synchronize()
        }
    }

    /// Load model from UserDefaults
    func loadModel<T: SFModel>(forKey key: String, userOnly: Bool) -> T? {
        if let json = defaults.object(forKey: combine(key, userOnly: userOnly)) {
            return SFModel.fromJSON(json)
        }

        return nil
    }

    /// Save an array of models to UserDefaults
    func saveModels<T: SFModel>(_ models: [T]?, forKey key: String, userOnly: Bool) {
        if let models = models {
            let json = models.toJSON()
            defaults.set(json, forKey: combine(key, userOnly: userOnly))
            defaults.synchronize()
        }
    }

    /// Load an array of models from UserDefaults
    func loadModels<T: SFModel>(forKey key: String, userOnly: Bool) -> [T]? {
        if let json = defaults.object(forKey: combine(key, userOnly: userOnly)) {
            return SFModel.fromJSONArray(json)
        }
        return nil
    }

    /// Remove for key
    func remove(_ key: String, userOnly: Bool) {
        defaults.removeObject(forKey: combine(key, userOnly: userOnly))
        defaults.synchronize()
    }

    private func combine(_ key: String, userOnly: Bool) -> String {
        return key
    }
}

