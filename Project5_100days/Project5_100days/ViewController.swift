//
//  ViewController.swift
//  Project5_100days
//
//  Created by user226947 on 12/22/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    //var usedWords = [String]()
    var currentGame = CurrentGame(mainWord: "", guessedWords: [String]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        let userDefaults = UserDefaults.standard
        if let loadedState = userDefaults.object(forKey: "currentGame") as? Data {
            let decoder = JSONDecoder()
            if let decodedState = try? decoder.decode(CurrentGame.self, from: loadedState) {
                currentGame = decodedState
            }
        }
        
        if currentGame.mainWord.isEmpty {
            startGame()
        }
        else {
            title = currentGame.mainWord
            tableView.reloadData()
        }
        
    
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        currentGame.mainWord = title ?? "whoa"
        currentGame.guessedWords.removeAll(keepingCapacity: true)
        //usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(currentGame) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "currentGame")
        } else {
            print("Failed to save people.")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return usedWords.count
        return currentGame.guessedWords.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        //cell.textLabel?.text = usedWords[indexPath.row]
        
        cell.textLabel?.text = currentGame.guessedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if !isPossible(word: lowerAnswer) {
            showErrorMessage(title: "Word not recodnized", message: "Can't make them up")
        }
        else if !isOriginal(word: lowerAnswer) {
            showErrorMessage(title: "Word already used", message: "Be original")
        }
        else if !isReal(word: lowerAnswer) {
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title!.lowercased()).")
        }
        else {
            //usedWords.insert(answer, at: 0)
            currentGame.guessedWords.insert(answer, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            
            //currentGame.guessedWords = usedWords
            save()
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        func showErrorMessage(title: String, message: String) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
                
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        //return !usedWords.contains(word)
        return !currentGame.guessedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        
        if word.count < 3 {
            return false
        }
        
        if word == title {
            return false
        }
        
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

}

