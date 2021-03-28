//
//  AlunoAPI.swift
//  Agenda
//
//  Created by ArjMaster on 22/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

import Alamofire

class AlunoAPI: NSObject {
    
    // MARK: - Atributos
    
    lazy var urlPadrao:String = {
        guard let url = Configuracao().getUrlPadrao() else { return "" }
        
        return url
    }()
    
    //MARK: - GET
        
    func recuperaAlunos(completion:@escaping() -> Void) {
        Alamofire.request(urlPadrao+"api/aluno", method: .get).responseJSON { (response) in
            switch response.result {
            case .success:
                if let resposta = response.result.value as? Dictionary<String, Any> {
                    self.serializaAlunos(resposta)
                    completion()
                }
                break
            case .failure:
                print(response.error!)
                completion()
                break
            }
        }
    }
    
    func recuperaUltimosAlunos(_ versao:String, completion:@escaping() -> Void) {
        Alamofire.request(urlPadrao+"api/aluno/diff", method: .get, headers: ["datahora":versao]).responseJSON { (response) in
            switch response.result {
            case .success:
                if let resposta = response.result.value as? Dictionary<String, Any> {
                    self.serializaAlunos(resposta)
                }
                completion()
                break
            case .failure:
                print("FALHA")
                break
            }
        }
    }
    
    //MARK: - PUT
    
    func salvarAlunosServidor(parametros:Array<Dictionary<String, Any>>, completion:@escaping(_ salvo:Bool) -> Void) {
        guard let url = URL(string: urlPadrao + "api/aluno/lista") else {return}
        
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        let json = try! JSONSerialization.data(withJSONObject: parametros, options: [])
        req.httpBody = json
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(req).responseData {
            (resposta) in if resposta.error == nil {
                completion(true)
            }
        }
    }
    
    // MARK: - DELETE
    
    func deletaAluno(id:String, completion:@escaping(_ apagado:Bool) -> Void) {
        Alamofire.request(urlPadrao+"api/aluno/\(id)", method: .delete).responseJSON { (resposta) in
            switch resposta.result {
            case .success:
                completion(true)
                break
            case .failure:
                completion(false)
                print(resposta.result.error!)
                break
            }
        }
    }
    
    // MARK: - Serialização
    
    func serializaAlunos(_ resposta:Dictionary<String, Any>) {
        guard let listaDeAlunos = resposta["alunos"] as? Array<Dictionary<String, Any>> else {return}
        for dicionarioDeAluno in listaDeAlunos {
            guard let status = dicionarioDeAluno["desativado"] as? Bool else { return }
            if status {
                guard let idDoAluno = dicionarioDeAluno["id"] as? String else { return }
                guard let UUIDAluno = UUID(uuidString: idDoAluno) else { return }
                if let aluno = AlunoDAO().recuperaAlunos().filter({ $0.id == UUIDAluno }).first {
                    AlunoDAO().deletaAluno(aluno: aluno)
                }
            } else{
                AlunoDAO().salvaAluno(dicionarioDeAluno: dicionarioDeAluno)
            }
        }
        AlunoUserDefaults().salvarVersao(resposta)
    }
    
}
