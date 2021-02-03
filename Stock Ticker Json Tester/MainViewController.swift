//
//  MainViewController.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/24/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource  {

    @IBOutlet var sortButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var dateLabel: UILabel!
    //context for core data
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var stocks: [Stock] = []
    var symbols: [Symbol]?
    var isDragEnabled = false
    var session = URLSession(configuration: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortButton.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        getSymbols()
        let date = NSDate() as Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
        
        
        //create stock objects from symbols in core data
        populateStocks()
        
        //for debuggin
        //printStocks()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //update stock values
        getAllStockPrices()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //give AddStockViewController access to this view controller
        if let addStockTableViewController = segue.destination as? AddStockTableViewController  {
            addStockTableViewController.mainTableViewController = self
        }
        
        
        //send selected row's data to the StockDetailsViewController
        if let stockDetailViewController = segue.destination as? StockDetailViewController {
            if let selectedStock = sender as? Stock {
                stockDetailViewController.stockData = selectedStock
            }
        }
        
        
    }
    
    @IBAction func sortPressed(_ sender: Any) {
        
        if self.isDragEnabled {
            self.tableView.isEditing = false
            self.isDragEnabled = false
            sortButton.titleLabel?.text = "Sort"
            sortButton.backgroundColor = .systemBlue
        }
        else {
            self.isDragEnabled = true
            self.tableView.isEditing = true
            sortButton.titleLabel?.text = "Done"
            sortButton.backgroundColor = .systemRed
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Stock Population Methods
    
    //Creates Stock object in a [Symbol]
    func populateStocks(){
        
        //unwrap symbols?
        guard let symbols = symbols else {return}
        
        for symbol in symbols {
            buildStockObject(symbol, nil)
        }
        
   }
    
    /*
     For building a Stock instance from Symbol object
     if index parameter is NOT nil, it places new Stock at that position and updates the indexes for stock and symbol arrays
     else it adds the stock to the end of the stocks array
     */
    func buildStockObject(_ symbolObject: Symbol,_ index: Int?){
        
        let newStock = Stock()
        
        //populate object
        if let symbol = symbolObject.symbol,
           let exchange = symbolObject.exchange,
           let currency = symbolObject.currency,
           let country = symbolObject.country,
           let name = symbolObject.name {
            newStock.symbol = symbol
            newStock.name = name
            newStock.index = Int(symbolObject.index)
            newStock.exchange = exchange
            newStock.currency = currency
            newStock.country = country
        }
        print("newStock object's symbol = " + newStock.symbol)
        /*
         add newStock to the end of [Stock] or at the
         proper index
         */
        if let index = index {
            newStock.index = index
            stocks.insert(newStock, at: index)
            symbols?.insert(symbolObject, at: index)
            getStockPrice(newStock)
            setStockIndex()
        } else {
            stocks.append(newStock)
        }
        
        print("created \(String(describing: newStock.symbol)) Stock object")
        
    }
    
    //gets data for all elements in stocks array
    func getAllStockPrices(){
        for stock in stocks{
            getStockPrice(stock)
        }
    }
    
    //Runs URLSession to retrieve intividual stock data
    func getStockPrice(_ stock: Stock?){
        
        guard let stock = stock else {
            print("stock parameter nil in getStockPrice()")
            return
        }
        
        let symbol = stock.symbol
        //crate the URL String.  Can be comined with next step
        let urlString: String = "https://finnhub.io/api/v1/quote?symbol=" + symbol + "&token=c02icuf48v6vhdkgvlc0"
        
        //crate URL object based on the urlString
        guard let url = URL(string: urlString) else {
            print("Bad url")
            return
        }
        
        /*
         URLSession is essentially a place to have URL tasks.
         We created the URLSession as a variable above.
         
         session.dataTask starts a new task task of retrieving data
         (with: url) sends the url object
         
         This is a separate thread running alongside the main
         basically it's running in the background
         
         (data, responce, error)
         a completion handler (things to do when things are done)
         data = data retuned from the internet (if any)
         response = a place for metadata to be recieved (if any)
         error = a place for error codes (if any)
         
         The entire block is first set up. It's not run until
         it gets to .resume()
         */
        session.dataTask(with: url){ (data, response, error) in
            //this will run AFTER the data task is finished
            //check if data is NOT nil (something was sent back)
            guard let data = data else {print("Bad Data"); return}
            
            do {
                
                /*
                 Parse JSON data
                 
                 take the JSON sata as it is
                 parameters:
                 data =  the raw data recieved
                 options = still figuring this one out
                 as AnyObject - This JSON is a complex set of dictionaries, so we're accepting it as
                 whatever type it currently is, and we'll unwrap it as we go.
                 */
                let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                
                print(json)
                
                //get necessary information from dictionary
                if let open$ = json["o"] as? Double,
                   let previousClose$ = json["pc"] as? Double,
                   let high$ = json["h"] as? Double,
                   let low$ = json["l"] as? Double,
                   let current$ = json["c"] as? Double{
                    stock.open$ = open$
                    stock.previousClose$ = previousClose$
                    stock.high$ = high$
                    stock.low$ = low$
                    stock.current$ = current$
                }
                
                
                print("completed fetching \(symbol)'s data")
                
                /*
                 Send notification to calling ViewController that this fetch instance is complete.
                 
                 We're currently running in a background thread, this breaks back into the main
                 thread.
                 */
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            }
            catch {
                print("JSON ERROR")
            }
            
        }.resume()
        
    }
    
    //reset all Stock and Symbol object's index based on their current position in array
    func setStockIndex(){
        for (index, stock) in stocks.enumerated() {
            stock.index = index
        }
        guard let symbols = symbols else {return}
        for (index, symbol) in symbols.enumerated() {
            symbol.index = Int64(index)
        }
    }
    
    //print function for debuggin stock and symbol arrays
    func printStocks(){
        for (index, stock) in stocks.enumerated() {
            print("\(index) = \(stock.index) = \(stock.name)")
        }
        guard let symbols = symbols else {return}
        for (index, symbol) in symbols.enumerated() {
            print("\(index) = \(String(describing: symbol.index)) = \(String(describing: symbol.name!))")
        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Table View Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create new cell object
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockDataTableViewCell
        
        //send this cell's data to its view controller
        let stock = stocks[indexPath.row]
        
        cell.symbol?.text = stock.symbol
        cell.name?.text = stock.name
        cell.currentPrice?.text = String (format: "$%.2f", stock.current$)
        let diff = stock.current$ - stock.open$
        cell.priceDiff?.text = String (format: "%.2f", diff)
        if (diff >= 0){
            cell.priceDiff?.textColor = .green
        } else {
            cell.priceDiff?.textColor = .red
        }
        
        return cell
    }
    
    /*
     Add delete button when swiping right on a cell
     
     It will throw an error until you're finished
     */
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        /*
         Creates the action for deleting
         .destructive style allows for a deleting action / use .normal for other things
         title = nill since we're gunna use the system trashcan
         */
        let deleteAction = UIContextualAction(style: .destructive, title: nil){
            //still figuring this out but it's necessary
            (_, _, completionHandler) in
            
            //get selected Stock and symbol object
            let stock = self.stocks[indexPath.row]
            let symbol = self.symbols?[indexPath.row]
            //get stock's index so we can delete it from symbols
            let index = stock.index
            
            //delete this stock from stocks
            self.stocks.remove(at: index)
            
            //delete symbol from symbol array AND context
            self.symbols!.remove(at: index)
            self.context!.delete(symbol!)
            
            //refresh the stock indexes
            self.setStockIndex()
            
            //update the core data
            do {
                try self.context!.save()
            } catch {
                print("Core Data not updated in trailingSwipe... method")
            }
            
            self.printStocks()
            
            self.tableView.reloadData()
            
            //indicates the code actually happened
            completionHandler(true)
        }
        //set the picture to the system trash can
        deleteAction.image = UIImage(systemName: "trash")
        //change the background color to red
        deleteAction.backgroundColor = .systemRed
        
        
        //put action into a swipe configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        //return the configuration
        return configuration
        
    }
    
    //Send data to detail view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStock = stocks[indexPath.row]
        performSegue(withIdentifier: "moveToDetails", sender: selectedStock)
    }
    
    
    //Drag and Drop Reordering of Cells
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.stocks[sourceIndexPath.row]
        
        //edit tableView
        stocks.remove(at: sourceIndexPath.row)
        stocks.insert(movedObject, at: destinationIndexPath.row)
        
        //edit symbols
        if let movedSymbol = self.symbols?[sourceIndexPath.row]{
            symbols?.remove(at: sourceIndexPath.row)
            symbols?.insert(movedSymbol, at: destinationIndexPath.row)
        }
        //set object's indexes
        setStockIndex()
        
        //save to core data
        do {
            try self.context!.save()
        } catch {
            print("Save CD failed in tableView() moveRow")
        }
        
    }
    
        
        
        
        
        
        
        
        
        
        
        
        // MARK: - Core Data fetching and saving
        func getSymbols(){
            do {
            //set up request
            let request = Symbol.fetchRequest() as NSFetchRequest<Symbol>
            
            //sort fetch results
            let sortIndex = NSSortDescriptor(key: "index", ascending: true)
            request.sortDescriptors = [sortIndex]
            
            //fetch core data
            self.symbols = try context!.fetch(request)
            }
            catch {
                print("Getting core data failed")
            }
            
        }
        
        
        
        
        
        

        /*
        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }
        */

        /*
        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
        */

        /*
        // Override to support rearranging the table view.
        override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

        }
        */

        /*
        // Override to support conditional rearranging of the table view.
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the item to be re-orderable.
            return true
        }
        */

        /*
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

    }


