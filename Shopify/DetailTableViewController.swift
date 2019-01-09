//
//  DetailTableViewController.swift
//  Shopify
//
//  Created by John Peng on 2019-01-07.
//  Copyright © 2019 John Peng. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    var products: [Product] = []
    var collectionID: String = ""
    
    typealias objectJSON = [Any]
    typealias arrayJSON = [String: Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        fetchID()
    }
}

extension DetailTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detail_cells", for: indexPath)
        
        if let acell = cell as? DetailTableViewCell {
            acell.title.text = products[indexPath.row].title
            acell.vendor.text = products[indexPath.row].vendor
            acell.bodyHTML.text = products[indexPath.row].body_html
            acell.type.text = products[indexPath.row].type
            
            do {
                if let url = URL(string: products[indexPath.row].url) {
                    let data = try Data(contentsOf: url)
                    acell.productImg.image = UIImage(data: data)
                }
            } catch {
                print(error)
            }
            
            return acell
        }
        
        return cell
    }
}

extension DetailTableViewController {
    
    func fetchID() {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let link = "https://shopicruit.myshopify.com/admin/collects.json?collection_id=\(collectionID)"
        
        guard let url = URL(string: "\(link)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6") else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling id GET")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive id data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? arrayJSON else {
                        print("Unexpected id json type")
                        return
                }
                
                guard let collects = json["collects"] as? objectJSON else {
                    print("Unexpected id array type")
                    return
                }
                
                for col in collects {
                    guard let collect = col as? arrayJSON else {
                        print("Unexpected id element type")
                        return
                    }
                    
                    if let id = collect["product_id"] as? Int {
                        let product = Product.init(aid: String(id))
                        self.products.append(product)
                    }
                }
                
                DispatchQueue.main.async {
                    self.fetchProduct(sp: spinner)
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func fetchProduct(sp: UIView) {
        
        if products.count == 0 { return }
        
        let id_string = products.map { String($0.id) }
            .joined(separator: ",")

        let link = "https://shopicruit.myshopify.com/admin/products.json?ids=\(id_string)"
        
        guard let url = URL(string: "\(link)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6") else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? arrayJSON else {
                        print("Unexpected json type")
                        return
                }
                
                guard let collects = json["products"] as? objectJSON else {
                    print("Unexpected product array type")
                    return
                }
                
                for col in collects {
                    guard let collect = col as? arrayJSON else {
                        print("Unexpected product element type")
                        return
                    }
                    
                    guard let image = collect["image"] as? arrayJSON else {
                        print("Unexpected product element type")
                        return
                    }
                    
                    if let id = collect["id"] as? Int,
                        let title = collect["title"] as? String,
                        let vendor = collect["vendor"] as? String,
                        let body = collect["body_html"] as? String,
                        let type = collect["product_type"] as? String,
                        let url = image["src"] as? String {
                        
                        for product in self.products where product.id == String(id) {
                            product.title = title
                            product.vendor = vendor
                            product.body_html = body
                            product.url = url
                            product.type = "TYPE: \(type.uppercased())"
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    UIViewController.removeSpinner(spinner: sp)
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}
