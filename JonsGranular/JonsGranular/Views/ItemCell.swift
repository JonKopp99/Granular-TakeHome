//
//  ItemCell.swift
//  JonsGranular
//
//  Created by Jonathan Kopp on 5/30/20.
//  Copyright © 2020 Jonathan Kopp. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    var item: Item?
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var itemLabel: UILabel!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.size.width -= 20
            frame.origin.x = 10
            super.frame = frame
            // Add a shadow to new adjusted frame
            self.addShadow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    // Reset for reuse
    func reset() {
        self.item = nil
        self.imgView.image = nil
        self.itemLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard item != nil else {
            return
        }
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imgView.image = #imageLiteral(resourceName: "Kirby")
        imgView.downloadAndSave(from: item!.imgURL())
        imgView.layer.borderWidth = 5
        imgView.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor
        itemLabel.text = item?.name ?? "Item"
    }
    
    func addShadow() {
        self.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 7.5
        layer.masksToBounds = true
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 15).cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let colors = [#colorLiteral(red: 0, green: 0.6745098039, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.6498066187, blue: 0.2595749497, alpha: 1),#colorLiteral(red: 1, green: 0.6632423401, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.2980392157, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1),#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)]
        if selected {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundColor = colors.randomElement() ?? .white
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundColor = .white
            })
        }
    }

}
