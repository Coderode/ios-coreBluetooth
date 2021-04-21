//
//  tableCell.swift
//  SerialCommunication
//
//  Created by Sandeep on 21/04/21.
//

import UIKit

class TableCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(name: String){
        self.nameLabel.text = name
    }
}
