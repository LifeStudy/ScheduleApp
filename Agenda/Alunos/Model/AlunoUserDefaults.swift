//
//  AlunoUserDefaults.swift
//  Agenda
//
//  Created by ArjMaster on 28/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

class AlunoUserDefaults: NSObject {
    
    let preferencias = UserDefaults.standard
    
    func salvarVersao(_ json:Dictionary<String, Any>) {
        guard let versao = json["momentoDaUltimaModificacao"] as? String else { return }
        preferencias.set(versao, forKey: "ultima-versao")
    }
    
    func recuperaUltimaVersao() -> String? {
        let versao = preferencias.object(forKey: "ultima-versao") as? String
        return versao
    }
}
