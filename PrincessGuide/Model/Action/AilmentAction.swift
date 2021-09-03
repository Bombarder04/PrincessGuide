//
//  AilmentAction.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/26.
//  Copyright © 2018 zzk. All rights reserved.
//

import Foundation

class AilmentAction: ActionParameter {
    
    var ailment: Ailment {
        return Ailment(type: rawActionType, detail: actionDetail1)
    }
    
    override var actionValues: [ActionValue] {
        return [
            ActionValue(initial: String(actionValue1), perLevel: String(actionValue2), key: nil, startIndex: 1)
        ]
    }
    
    var chanceValues: [ActionValue] {
        return [
            ActionValue(initial: String(actionValue3), perLevel: String(actionValue4), key: nil, startIndex: 3)
        ]
    }
    
    var durationValues: [ActionValue] {
        return chanceValues
    }
    
    override func localizedDetail(of level: Int, property: Property = .zero, style: CDSettingsViewController.Setting.ExpressionStyle = CDSettingsViewController.Setting.default.expressionStyle) -> String {
        switch ailment.ailmentType {
        case .action:
            var result = ""
            switch ailment.ailmentDetail {
            case .some(.action(.haste)), .some(.action(.slow)):
                let format = NSLocalizedString("Multiple attack speed of %@ with [%@] for [%@]s.", comment: "")
                result = String(
                    format: format,
                    targetParameter.buildTargetClause(),
                    buildExpression(of: level, actionValues: actionValues, roundingRule: nil, style: style, property: property),
                    buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property)
                )
//            case .some(.action(.slow)):
//                let format = NSLocalizedString("Multiple attack speed of %@ with [%@] for [%@]s.", comment: "")
//                result = String(
//                    format: format,
//                    targetParameter.buildTargetClause(),
//                    buildExpression(of: level, actionValues: actionValues, roundingRule: nil, style: style, property: property),
//                    buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property)
//                )
            case .some(.action(.sleep)):
                let format = NSLocalizedString("Make %@ fall asleep for [%@]s.", comment: "")
                result = String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            case .some(.action(.faint)):
                let format = NSLocalizedString("Make %@ fall into faint for [%@]s.", comment: "")
                result = String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            case .some(.action(.theWorld)):
                let format = NSLocalizedString("Stop time on %@ for [%@]s.", comment: "")
                result = String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            default:
                let format = NSLocalizedString("%@ %@ for [%@]s.", comment: "")
                result = String(format: format, ailment.description, targetParameter.buildTargetClause(), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            }
            if actionDetail2 == 1 {
                let format = NSLocalizedString("%@ The effect will be released when taking damage.", comment: "")
                return String(format: format, result)
            } else {
                return result
            }
        case .dot:
            var result = ""
            switch ailment.ailmentDetail {
            case .some(.dot(.poison)):
                let format = NSLocalizedString("Poison %@ and deal [%@] damage per second for [%@]s.", comment: "")
                result = String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, roundingRule: .awayFromZero, style: style, property: property), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            case .some(.dot(.violentPoison)):
                let format = NSLocalizedString("Poison %@ violently and deal [%@] damage per second for [%@]s.", comment: "")
                result = String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, roundingRule: .awayFromZero, style: style, property: property), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            default:
                let format = NSLocalizedString("%@ %@ and deal [%@] damage per second for [%@]s.", comment: "")
                result = String(format: format, ailment.description, targetParameter.buildTargetClause(), buildExpression(of: level, roundingRule: .awayFromZero, style: style, property: property), buildExpression(of: level, actionValues: durationValues, roundingRule: nil, style: style, property: property))
            }
            if actionValue5 > 0 {
                result += String(format: NSLocalizedString(" This effect increases [%@]%% of base damage each tick.", comment: ""), actionValue5.roundedString(roundingRule: nil))
            }
            return result
        case .silence:
            let format = NSLocalizedString("Silence %@ with [%@]%% chance for [%@]s.", comment: "")
            return String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, actionValues: chanceValues, roundingRule: nil, style: style, property: property), buildExpression(of: level, roundingRule: nil, style: style, property: property))
        case .darken:
            let format = NSLocalizedString("Blind %@ with [%@]%% chance for [%@]s, physical attack has %d%% chance to miss.", comment: "")
            return String(format: format, targetParameter.buildTargetClause(), buildExpression(of: level, actionValues: chanceValues, roundingRule: nil, style: style, property: property), buildExpression(of: level, roundingRule: nil, style: style, property: property), 100 - actionDetail1)
        default:
            return super.localizedDetail(of: level, property: property, style: style)
        }
    }
}
