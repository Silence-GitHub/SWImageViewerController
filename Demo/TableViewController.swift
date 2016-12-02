//
//  TableViewController.swift
//  SWImageViewerController
//
//  Created by Kaibo Lu on 2016/12/1.
//  Copyright © 2016年 Kaibo Lu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rows")
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "View_images_cell", for: indexPath)
            cell.textLabel?.text = "View single and multiple images"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Delete_images_cell", for: indexPath)
        cell.textLabel?.text = "Delete images"
        return cell
    }

}
