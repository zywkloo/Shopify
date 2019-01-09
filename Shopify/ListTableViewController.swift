//
//  ListTableViewController.swift
//  Shopify
//
//  Created by John Peng on 2019-01-07.
//  Copyright © 2019 John Peng. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var contentOffSet = 0;
    var collections: [Collection] = [];
    var url = "https://shopicruit.myshopify.com/admin/custom_collections.json";
    var page = 1;
    var token = "c32313df0d0ef512ca64d5b336a0d7c6";
    
    typealias objectJSON = [Any]
    typealias arrayJSON = [String: Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailTableViewController,
            let index = tableView.indexPathForSelectedRow {
            viewController.collectionID = collections[index.row].collectionID
        }
    }
}

extension ListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return collections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell {
            cell.title.text = collections[indexPath.row].title
            cell.bodyHTML.text = collections[indexPath.row].bodyHTML
            do {
                if let url = URL(string: collections[indexPath.row].imgURL) {
                    let data = try Data(contentsOf: url)
                    cell.collectionImg.image = UIImage(data: data)
                }
            }
            catch{
                print(error)
            }
            return cell
        }
        
        
        return UITableViewCell.init()
    }
}


extension ListTableViewController {
    
    func setUI() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func fetchData() {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        guard let url = URL(string: "\(url)?page=\(page)&access_token=\(token)") else {
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

                guard let collectionArray = json["custom_collections"] as? objectJSON else {
                    print("Unexpected collection array type")
                    return
                }
                
                for col in collectionArray {
                    guard let collect = col as? arrayJSON else {
                        print("Unexpected collection element type")
                        return
                    }
                    
                    
                    guard let image = collect["image"] as? arrayJSON else {
                        print("Unexpected image type")
                        return
                    }
                    
                    guard let title = collect["title"] as? String,
                        let url = image["src"] as? String,
                        let id = collect["id"] as? Int,
                        let body = collect["body_html"] as? String else {
                            print("Unexpcted data type")
                            return
                    }
                    
                    let aCollection = Collection.init(aTtitle: title,
                                                      aURL: url,
                                                      aBody: body, aID: String(id))
                    self.collections.append(aCollection);
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    UIViewController.removeSpinner(spinner: spinner)
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}

extension UIViewController {
    class func displaySpinner(onView: UIView) -> UIView {
        
        let spinnerView = UIView(frame: UIApplication.shared.keyWindow!.bounds)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIView(frame: UIApplication.shared.keyWindow!.bounds).frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        spinnerView.addSubview(blurEffectView)
        
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            UIApplication.shared.keyWindow!.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    class func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
