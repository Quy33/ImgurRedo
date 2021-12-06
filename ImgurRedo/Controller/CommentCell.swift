//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    
    private var outerStackView = UIStackView()
        
    private var commentLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .yellow
        label.text = "Hello World"
        label.inset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        return label
    }()
    
    private var commentStackView = UIStackView()
    
    private var separators: [UIView] = []
    
//MARK: Cell header
    private var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var headerStackView = UIStackView()
    private var childLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
//MARK: Cell setup
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, comment: Comment) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup(separatorAmount: comment.level, isEmpty: comment.children.isEmpty)
        config(comment: comment.value, author: comment.author, isCollapsed: comment.isCollapsed, childrenCount: comment.children.count)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //MARK: Comment Setup
    private func setup(separatorAmount count: Int, isEmpty: Bool) {
        commentStackView = makeStackView(axis: .horizontal, distribution: .fill, color: .green, spacing: 10)
        outerStackView = makeStackView(axis: .vertical, distribution: .fill, color: .blue, spacing: 10)
        headerStackView = makeStackView(axis: .horizontal, distribution: .fill, color: .green, spacing: 10)
        
        separators = makeSeparator(amount: count)
        addSubViews(isEmpty: isEmpty)
        setConstraints(isEmpty: isEmpty)
    }
    private func addSubViews(isEmpty: Bool) {
        contentView.addSubview(outerStackView)
        outerStackView.addArrangedSubview(headerStackView)
        
        headerStackView.addArrangedSubview(authorLabel)
        if !isEmpty {
            headerStackView.addArrangedSubview(childLabel)
        }
        
        outerStackView.addArrangedSubview(commentStackView)
        for separator in separators {
            commentStackView.addArrangedSubview(separator)
        }
        commentStackView.addArrangedSubview(commentLabel)
    }
    private func setConstraints(isEmpty: Bool) {
        var constraints: [NSLayoutConstraint] = []
        
        //Comment Stack View
        constraints.append(outerStackView.topAnchor.constraint(
            equalTo: contentView.topAnchor)
        )
        constraints.append(outerStackView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor)
        )
        constraints.append(outerStackView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: 10)
        )
        constraints.append(outerStackView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor, constant: -10)
        )
        
        constraints.append(headerStackView.widthAnchor.constraint(equalTo: outerStackView.widthAnchor))
        
        constraints.append(commentStackView.widthAnchor.constraint(equalTo: outerStackView.widthAnchor))
        
        //Comment Header
        if !isEmpty {
            constraints.append(childLabel.heightAnchor.constraint(equalTo: authorLabel.heightAnchor))
        }
        //Comment Separator
        for separator in separators {
            constraints.append(separator.heightAnchor.constraint(equalTo: commentLabel.heightAnchor))
            constraints.append(separator.widthAnchor.constraint(equalToConstant: 5))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    //MARK: Small functions
    func config(comment: String, author: String, isCollapsed: Bool ,childrenCount count: Int){
        commentLabel.text = comment
        authorLabel.text = author
        childLabel.text = isCollapsed ? "X" : "\(count)"
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
    private func makeStackView(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, color: UIColor, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = color
        
        return stackView
    }
}

