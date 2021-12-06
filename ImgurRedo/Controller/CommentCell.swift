//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    private var separators: [UIView] = []
    
//MARK: Cell UIs
    private var outerStackView = UIStackView()
    private var commentStackView = UIStackView()
    private var headerStackView = UIStackView()
    
    private var commentLabel = PaddingLabel()
    private var authorLabel = PaddingLabel()
    private var childLabel = PaddingLabel()
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
        outerStackView = makeStackView(axis: .horizontal, distribution: .fill, color: .gray, spacing: 10)
        commentStackView = makeStackView(axis: .vertical, distribution: .fill, color: .lightGray, spacing: 0)
        headerStackView = makeStackView(axis: .horizontal, distribution: .fill, color: .clear, spacing: 10)
        
        let normalInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let commentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        commentLabel = makeLabel(numberOfLines: 0, color: .clear, inset: commentInset, textAlignment: .left)
        authorLabel = makeLabel(numberOfLines: 1, color: .clear, inset: normalInset, textAlignment: .left)
        childLabel = makeLabel(numberOfLines: 1, color: .clear, inset: normalInset, textAlignment: .center)
        
        separators = makeSeparator(amount: count)
        addSubViews(isEmpty: isEmpty)
        setConstraints(isEmpty: isEmpty)
    }
    private func addSubViews(isEmpty: Bool) {
        contentView.addSubview(outerStackView)
                
        separators.forEach{ outerStackView.addArrangedSubview($0) }
        outerStackView.addArrangedSubview(commentStackView)
        
        commentStackView.addArrangedSubview(headerStackView)
        commentStackView.addArrangedSubview(commentLabel)
        
        headerStackView.addArrangedSubview(authorLabel)
        headerStackView.addArrangedSubview(childLabel)
        
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
        
        separators.forEach {
            constraints.append($0.widthAnchor.constraint(equalToConstant: 5))
            constraints.append($0.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
        }
        
        constraints.append(commentStackView.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
        
        constraints.append(headerStackView.widthAnchor.constraint(equalTo: commentStackView.widthAnchor))
        
        constraints.append(commentLabel.widthAnchor.constraint(equalTo:  commentStackView.widthAnchor))
        
        constraints.append(authorLabel.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor))
        constraints.append(childLabel.widthAnchor.constraint(equalToConstant: 50))
        
        NSLayoutConstraint.activate(constraints)
    }
    //MARK: Small functions
    func config(comment: String, author: String, isCollapsed: Bool ,childrenCount count: Int){
        commentLabel.text = comment
        authorLabel.text = author
        childLabel.text = isCollapsed ? "X" : "\(count)"
        childLabel.isHidden = count == 0 ? true : false
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
    private func makeLabel(numberOfLines lines: Int, color: UIColor, inset: UIEdgeInsets,textAlignment alignment: NSTextAlignment) -> PaddingLabel {
        let label = PaddingLabel()
        label.numberOfLines = lines
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = color
        label.text = "Hello World"
        label.inset = inset
        label.textAlignment = alignment
        return label
    }
}

