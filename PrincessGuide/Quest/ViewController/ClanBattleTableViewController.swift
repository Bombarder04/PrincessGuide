//
//  ClanBattleTableViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/11.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

class ClanBattleTableViewController: UITableViewController, DataChecking {
    
    enum Mode {
        case normal
        case easy
    }
    
    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var clanBattles = [ClanBattle]()
    
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
            Master.shared.getClanBattles { (clanBattles) in
                // preload
                DispatchQueue.global(qos: .userInitiated).async {
//                    clanBattles.forEach {
//                        $0.preload()
//                    }
//                    clanBattles.forEach { _ = $0.rounds.last?.groups.last?.wave?.enemies.first?.enemy }
                    DispatchQueue.main.async {
                        LoadingHUDManager.default.hide()
                        self?.clanBattles = clanBattles.sorted { $0.period.startTime > $1.period.startTime }
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
        return clanBattles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HatsuneEventTableViewCell.description(), for: indexPath) as! HatsuneEventTableViewCell
        let clanBattle = clanBattles[indexPath.row]
        cell.configure(for: clanBattle.rounds.last?.groups.last?.wave?.enemies.first?.enemy?.unit.unitName ?? "", subtitle: clanBattle.name, unitID: clanBattle.rounds.last?.groups.last?.wave?.enemies.first?.enemy?.unit.prefabId)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clanBattle = clanBattles[indexPath.row]
        let vc = QuestEnemyTableViewController(clanBattle: clanBattle, mode: mode)
        vc.hidesBottomBarWhenPushed = true
        vc.navigationItem.title = clanBattle.name
        navigationController?.pushViewController(vc, animated: true)
    }

}
