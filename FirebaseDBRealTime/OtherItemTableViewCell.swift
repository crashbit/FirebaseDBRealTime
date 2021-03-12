//
//  OtherItemTableViewCell.swift
//  FirebaseDBRealTime
//
//  Created by Germán Santos Jaimes on 12/03/21.
//

import UIKit

class OtherItemTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var quantity: UILabel!
    
    override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
    }
    
}
