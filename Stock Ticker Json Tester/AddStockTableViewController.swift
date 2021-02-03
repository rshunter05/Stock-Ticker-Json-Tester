//
//  AddStockTableViewController.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/18/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    
    
}

class AddStockTableViewController: UITableViewController, UISearchBarDelegate {
        
    @IBOutlet var searchBar: UISearchBar!
    
    public var suggestions: [[String]] = [] //stores  suggestions
    public var count = 0 //number of suggestions from search
    public var mainTableViewController: MainViewController? = nil
    
    //For URLSession
    private let session = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //must set THIS view controller as the search bar delegate
        searchBar.delegate = self
        searchBar.backgroundColor = .lightGray
        
        
    }

    
    
    
    //MARK: - Search Bar Methods
    
    //Update table options when text is changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text change")
        if (searchText.count == 0){
            self.count = 0
            self.tableView.reloadData()
            return
        }
        if let dataTask = dataTask {
            dataTask.cancel() //cancel task
        }
        getSuggestions(searchText)
        
    }
    
    //gets stock search results based upon what's currently in the search bar
    func getSuggestions(_ str: String){
        //empty the suggestions from the array
        suggestions.removeAll()
        //create url string and object
        let urlString: String = "https://finnhub.io/api/v1/search?q=" + str + "&token=c02icuf48v6vhdkgvlc0"
        guard let url = URL(string: urlString) else {
            print("Bad url")
            return
        }
        
        
        self.dataTask = session.dataTask(with: url){ (data, response, error) in
            
            //check if data is NOT nil (something was sent back)
            guard let data = data else {print("Bad Data"); return}
            
            //parseJSON
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                
                guard let count = json["count"] as? Int else{
                    self.count = 0
                    print("failed to unwrap suggestion count")
                    return
                }
                self.count = count
                if (self.count > 20){
                    self.count = 20
                }
                print(count)
                
                /*
                 Parse JSON results
                 results section is an array of String:String dictionaries
                 */
                guard let results = json["result"] as? [NSDictionary] else {
                    self.count = 0
                    print("Failed unwrapping suggestion results")
                    return
                }
                
                for (index, result) in results.enumerated() {
                    if (index == 20) {
                        break
                    }
                    if let symbol = result["symbol"] as? String,
                        let description = result["description"] as? String{
                        self.suggestions.append([symbol, description])
                    }
                }
                
                //Go back to main thread to refresh the table
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            } catch {
                print("Search Suggestion URLSession Failed")
            }
        }
    //since we have a global task variable, we must do this differently than the main VC
    dataTask?.resume()
        
        
    }
    
    
    
    
    
    
    
    // MARK: - Table Build Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SuggestionTableViewCell
        
        
        //populate cell information
        let suggestion = suggestions[indexPath.row]
        cell.symbol?.text = suggestion[0]
        cell.name?.text = suggestion[1]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get this row's symbol and company name
        let newSymbol = suggestions[indexPath.row][0]
        let newName = suggestions[indexPath.row][1]
        
        //ask if user wants to add this stock to list
        addStockAlert(newSymbol, newName)
        
    }
    
    
    
    
    
    
    
    
    //MARK: - Adding new Stock to list
    
    /*
     Ask user if they wish to add the given stock
     return 0 for no, and 1 for yes
     */
    func addStockAlert(_ symbol: String, _ name: String){
        
        /*
         CREATE ALERT OBJECT
         set strings for title and message
         set style to .alert
         .actionSheet is other option (see button #2)
         */
        let alert = UIAlertController(title: "Add \(symbol)",
                                      message: "Add \(name) to your stock list?",
                                      preferredStyle: .alert)
        
        /*
         Add Cancel button
         title = text on the button
         style = a set of prebuilt button formats
         handles = what happens when button is hit
                   it must be formatted {_ in <code>}
         
         */
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        /*
         Add Stock button starts the process of adding a new Stock to the main list
         */
        alert.addAction(UIAlertAction(title: "Add Stock", style: .default, handler: {action in self.addNewStock(symbol)}))
        
        self.present(alert, animated: true)
    }

   
    /*
     creates new stock object
     places new object in front of Stock array
     refreshes main stock Table View
     */
    func addNewStock(_ symbol: String){
        //create Stock object
        
        let newSymbol = Symbol(context: (mainTableViewController?.context)!)
        
        newSymbol.symbol = symbol
        newSymbol.index = 0
        
        //get infomation from URL
        //build URL string
        let urlString: String = "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)&token=c02icuf48v6vhdkgvlc0"
        
        //build URL object
        guard let url = URL(string: urlString) else {
            print("Bad URL in addNewStock()")
            return
        }
        
        //Start URL session
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            //unwrap data
            guard let data = data else {
                print("Bad Data in addNewStock()");
                return
            }
        
            //get json data and parse it
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                
                if let name = json["name"] as? String,
                   let exchange = json["exchange"] as? String,
                   let currency = json["currency"] as? String,
                   let country = json["country"] as? String {
                    newSymbol.name = name
                    print("currency = \(currency)")
                    newSymbol.currency = currency
                    newSymbol.country = country
                    
                    if (exchange.contains("NASDAQ")){
                        newSymbol.exchange = "NASDAQ"
                    }
                    else if (exchange.contains("NEW YORK STOCK EXCHANGE")){
                        newSymbol.exchange = "NYSE"
                    } else {
                        newSymbol.exchange = "?"
                    }
                    
                }
                
                
                self.mainTableViewController?.buildStockObject(newSymbol, 0)
                
                self.mainTableViewController?.getStockPrice(self.mainTableViewController?.stocks[0])
                    
                //save context to CD
                do {
                    try self.mainTableViewController!.context!.save()
                    
                } catch {
                    print("Save CD failed in addNewStock()")
                }
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("JSON failed in addNewStock()")
            }
            
        }.resume()
        
        
        //pop off current VC
        
        
    }
    
}
