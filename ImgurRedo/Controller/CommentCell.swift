//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    
    private var separatorCount = 0
    private var hasChild = false
    
    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .yellow
        label.text = "Hello World"
        return label
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        
        return stackView
    }()
    
    private var separators: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, count: Int) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorCount = count
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeSeparator(amount: Int) -> [UIView] {
        var results: [UIView] = []
        for _ in 0 ..< amount {
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = .red
            results.append(separator)
        }
        return results
    }
    
    private func addSubViews() {
        contentView.addSubview(stackView)
        for separator in separators {
            stackView.addArrangedSubview(separator)
        }
        stackView.addArrangedSubview(label)
    }
    private func setConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        //Stack View
        constraints.append(stackView.topAnchor.constraint(
            equalTo: contentView.topAnchor)
        )
        constraints.append(stackView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor)
        )
        constraints.append(stackView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: 10)
        )
        constraints.append(stackView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor, constant: -10)
        )
        
        //Separator
        for separator in separators {
            constraints.append(separator.heightAnchor.constraint(equalTo: stackView.heightAnchor))
            constraints.append(separator.widthAnchor.constraint(equalToConstant: 5))
        }
        
        //Label
        constraints.append(label.heightAnchor.constraint(equalTo: stackView.heightAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setup() {
        separators = makeSeparator(amount: separatorCount)
        addSubViews()
        setConstraints()
    }
    func config(text: String){
        label.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

