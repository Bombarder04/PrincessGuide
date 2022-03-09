//
//  DungeonBossTableViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/6/14.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

class DungeonBossTableViewController: UITableViewController, DataChecking {
    
    private var dungeons = [Dungeon]()
    
    let refresher = RefreshHeader()
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateEnd(_:)), name: .preloadEnd, object: nil)
        
        tableView.mj_header = refresher
        refresher.refreshingBlock = { [weak self] in self?.check() }
        
        tableView.keyboardDismissMode = .onDrag
        tableView.register(HatsuneEventTableViewCell.self, forCellReuseIdentifier: HatsuneEventTableViewCell.description())
        tableView.rowHeight = 84
        tableView.estimatedRowHeight = 0
        tableView.tableFooterView = UIView()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        loadData()
    }
    
    @objc private func handleUpdateEnd(_ notification: NSNotification) {
        loadData()
    }
    
    private func loadData() {
        LoadingHUDManager.default.show()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Master.shared.getDungeons { (dungeons) in
                // preload
                DispatchQueue.global(qos: .userInitiated).async {
                    dungeons.forEach { $0.waves.forEach { _ = $0.enemies.first?.enemy } }
                    DispatchQueue.main.async {
                        LoadingHUDManager.default.hide()
                        self?.dungeons = dungeons.sorted { $0.dungeonAreaId > $1.dungeonAreaId }
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dungeons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HatsuneEventTableViewCell.description(), for: indexPath) as! HatsuneEventTableViewCell
        let dungeon = dungeons[indexPath.row]
        let unit = dungeon.waves.first?.enemies.first?.enemy?.unit
        cell.configure(for: "\(unit?.unitName ?? "")", subtitle: dungeon.dungeonName, unitID: unit?.prefabId)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dungeon = dungeons[indexPath.row]
        
        /* debug */
        /*
        let enemy = DispatchSemaphore.sync { (closure) in
            Master.shared.getEnemies(enemyID: 501010401, callback: closure)
        }?.first
        if let enemy = enemy {
            let vc = EDTabViewController(enemy: enemy)
            vc.hidesBottomBarWhenPushed = true
            vc.navigationItem.title = enemy.unit.unitName
            navigationController?.pushViewController(vc, animated: true)
        }
         */
        
        if let enemy = dungeon.waves.first?.enemies.first?.enemy {
            if enemy.parts.count > 0 || dungeon.waves.count > 0 {
                let vc = QuestEnemyTableViewController(waves: dungeon.waves)
                vc.hidesBottomBarWhenPushed = true
                vc.navigationItem.title = enemy.unit.unitName
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = EDTabViewController(enemy: enemy)
                vc.hidesBottomBarWhenPushed = true
                vc.navigationItem.title = enemy.unit.unitName
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
