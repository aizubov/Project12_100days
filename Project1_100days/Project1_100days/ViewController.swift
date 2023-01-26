//
//  ViewController.swift
//  Project1_100days
//
//  Created by user226947 on 12/7/22.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var viewNum = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        let fm = FileManager.default
        
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }

        pictures.sort()
        
        let userDefaults = UserDefaults.standard
        viewNum = userDefaults.object(forKey: "ViewCount") as? [String: Int] ?? [String: Int]()

    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "Views: \(viewNum[pictures[indexPath.row], default: 0])"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            
            viewNum[pictures[indexPath.row], default: 0] += 1
            let userDefaults = UserDefaults.standard
            userDefaults.set(viewNum, forKey: "ViewCount")
            vc.currentPos = indexPath.row + 1
            vc.total = pictures.count
            
            navigationController?.pushViewController(vc, animated: true)
            tableView.reloadRows(at: [indexPath], with: .none)
            
        }
    }
    
    @objc func shareTapped() {
        var items: [Any] = ["This app is cool, check it out!"]
        
        if let url = URL(string: "https://github.com/aizubov/Project1_100days") {
            items.append(url)
        }
        
        let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    
}
