//
//  ConsoleVariables.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/6.
//  Copyright © 2018 zzk. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let updateConsoleVariblesEnd = Notification.Name("update_console_variables_end")
    
}

class ConsoleVariables: Codable {
    
    static let `default` = ConsoleVariables.load() ?? ConsoleVariables()
    
    static let url = URL(fileURLWithPath: Path.library).appendingPathComponent("console_variables.json")
    
    var maxPlayerLevel = Constant.presetMaxPlayerLevel { didSet { save() } }
    
    var maxEquipmentRank = Constant.presetMaxRank { didSet { save() } }
    
    var coefficient = Coefficient.default { didSet { save() } }
    
    var maxEnemyLevel = Constant.presetMaxEnemyLevel { didSet { save() } }
    
    var skillCost = [Int: Int]() { didSet { save() } }
    
    var unitExperience = [Int: Int]() { didSet { save() } }
    
    func save() {
        try? JSONEncoder().encode(self).write(to: ConsoleVariables.url)
    }
    
    static func load() -> ConsoleVariables? {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? decoder.decode(ConsoleVariables.self, from: data)
    }
    
    private init() {

    }
    
    func rebuild() {
        handleDataUpdatingEnd()
    }
    
    func handleDataUpdatingEnd() {
        
        let group = DispatchGroup()
        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
            Master.shared.getMaxLevel { (maxLevel) in
                self?.maxPlayerLevel = maxLevel ?? Constant.presetMaxPlayerLevel
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
            Master.shared.getMaxEnemyLevel(callback: { (level) in
                self?.maxEnemyLevel = level ?? Constant.presetMaxEnemyLevel
            })
        }
        //        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
//            Master.shared.getCoefficient(callback: { (coefficient) in
//                self?.coefficient = coefficient ?? Coefficient.default
//            })
//        }
        
        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
            Master.shared.getMaxRank(callback: { (rank) in
                self?.maxEquipmentRank = rank ?? Constant.presetMaxRank
            })
        }
        
        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
            Master.shared.getSkillCost(callback: { (skillCost) in
                self?.skillCost = skillCost
            })
        }
        
        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
            Master.shared.getUnitExperience(callback: { (unitExperience) in
                self?.unitExperience = unitExperience
            })
        }
        
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: .updateConsoleVariblesEnd, object: nil)
            CDSettingsViewController.Setting.default = CDSettingsViewController.Setting()
        }
        
    }
    
}
