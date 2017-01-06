
//
//  ColorListCell.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 11/8/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//
import UIKit

final class ImageListCell: UITableViewCell {
    
    // MARK: Public
    
    var images = [UIImage]()
    var onImageSelected: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func select(item: Int, animated: Bool = false) {
        let indexPath = IndexPath(item: item, section: 0)
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
    }
    
    // MARK: Private
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private func configure() {
        selectionStyle = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
    }
}

extension ImageListCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = collectionView.bounds.height
        return CGSize(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.item]
        onImageSelected?(indexPath.item)
    }
}

private class ImageCell: UICollectionViewCell {
    
    // MARK: Public
    
    var image: UIImage? {
        get { return imageView?.image }
        set { imageView?.image = newValue }
    }
    override var isSelected: Bool {
        didSet { selectedView.isHidden = !isSelected }
    }
    
    override var isHighlighted: Bool {
        didSet { contentView.alpha = isHighlighted ? 0.9 : 1 }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    var imageWrapper : UIView?
    var imageView : UIImageView?
    private weak var selectedView: UIView!
    
    private func configure() {
        contentView.layer.borderWidth = 0.0
        
        imageWrapper = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
        imageView = UIImageView(frame: CGRect(x: 4, y: 4, width: self.frame.size.height - 8, height: self.frame.size.height - 8))
        imageWrapper?.addSubview(imageView!)
        contentView.addSubview(imageWrapper!)
        
        let selectedView = UIView()
        selectedView.layer.borderWidth = 4
        selectedView.layer.borderColor = selectedView.tintColor.cgColor
        selectedView.isUserInteractionEnabled = false
        selectedView.isHidden = !isSelected
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectedView)
        self.selectedView = selectedView
        
        let constraints = [
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|",
                options: [],
                metrics: nil,
                views: ["view": selectedView]
            ),
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[view]-0-|",
                options: [],
                metrics: nil,
                views: ["view": selectedView]
            )
            ].flatMap { $0 }
        contentView.addConstraints(constraints)
    }
}
