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
    private var networkManager = NetWorkManager()
    var hasImageLink = false
    var finishedDownload = false
    
//MARK: Cell UIs
    private var outerStackView = UIStackView()
    private var commentStackView = UIStackView()
    private var headerStackView = UIStackView()
    
    private var commentLabel = PaddingLabel()
    private var authorLabel = PaddingLabel()
    private var childLabel = PaddingLabel()
    private var childCountView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .clear
        return uiView
    }()
    private let bottomSeparator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .black
        return separator
    }()
    private var commentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
//MARK: Cell setup
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, comment: Comment) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .lightGray
        setup(separatorAmount: comment.level, isEmpty: comment.children.isEmpty)
        config(comment: comment.value, author: comment.author, isCollapsed: comment.isCollapsed, childrenCount: comment.children.count, image: comment.image)
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
        setProperties(count: count)
        addSubViews(isEmpty: isEmpty)
        setConstraints(isEmpty: isEmpty)
    }
    private func setProperties(count: Int) {
        outerStackView = makeStackView(axis: .horizontal, distribution: .fill, color: .clear, spacing: 5)
        commentStackView = makeStackView(axis: .vertical, distribution: .fill, color: .clear, spacing: 0)
        headerStackView = makeStackView(axis: .horizontal, distribution: .fill, color: .clear, spacing: 5)
        
        let normalInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        let childLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let commentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        let titleFont: UIFont = .systemFont(ofSize: 22, weight: .bold)
        let normalFont: UIFont = .systemFont(ofSize: 17)
        
        commentLabel = makeLabel(numberOfLines: 0, bgColor: .clear, inset: commentInset, textAlignment: .left, textColor: .black, font: normalFont)
        authorLabel = makeLabel(numberOfLines: 0, bgColor: .clear, inset: normalInset, textAlignment: .left, textColor: .black, font: titleFont)
        childLabel = makeLabel(numberOfLines: 1, bgColor: .gray, inset: childLabelInset, textAlignment: .center, textColor: .white, font: normalFont)
        
        separators = makeSeparator(amount: count)
    }
    private func addSubViews(isEmpty: Bool) {
        contentView.addSubview(outerStackView)
                
        separators.forEach{ outerStackView.addArrangedSubview($0) }
        outerStackView.addArrangedSubview(commentStackView)
        
        commentStackView.addArrangedSubview(headerStackView)
        commentStackView.addArrangedSubview(commentImage)
        commentStackView.addArrangedSubview(commentLabel)
        commentStackView.addArrangedSubview(bottomSeparator)
        
        headerStackView.addArrangedSubview(authorLabel)
        headerStackView.addArrangedSubview(childCountView)
        childCountView.addSubview(childLabel)
    }
    private func setConstraints(isEmpty: Bool) {
        var constraints: [NSLayoutConstraint] = []
        
        //Outer Stack View
        constraints.append(outerStackView.topAnchor.constraint(
            equalTo: contentView.topAnchor)
        )
        constraints.append(outerStackView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor)
        )
        constraints.append(outerStackView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: 0)
        )
        constraints.append(outerStackView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor, constant: 0)
        )
        
        separators.forEach {
            constraints.append($0.widthAnchor.constraint(equalToConstant: 10))
            constraints.append($0.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
        }
        
        //Comment Stack View
        constraints.append(commentStackView.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
        
        constraints.append(commentImage.widthAnchor.constraint(equalTo: commentStackView.widthAnchor))
        constraints.append(commentImage.heightAnchor.constraint(equalToConstant: 100))
        
        constraints.append(commentLabel.widthAnchor.constraint(equalTo:  commentStackView.widthAnchor))
        
        //Bottom of Comment Stack View
        constraints.append(bottomSeparator.widthAnchor.constraint(equalTo: commentStackView.widthAnchor)
        )
        constraints.append(bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
        )
        
        //Header Stack View
        constraints.append(headerStackView.widthAnchor.constraint(equalTo: commentStackView.widthAnchor)
        )
        
        constraints.append(authorLabel.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor)
        )
        constraints.append(authorLabel.topAnchor.constraint(equalTo: headerStackView.topAnchor)
        )
        constraints.append(authorLabel.bottomAnchor.constraint(equalTo: headerStackView.bottomAnchor)
        )
        
        constraints.append(childCountView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor))
        constraints.append(childCountView.widthAnchor.constraint(equalToConstant: 50))
        
        constraints.append(childLabel.topAnchor.constraint(equalTo: childCountView.topAnchor)
        )
        constraints.append(childLabel.bottomAnchor.constraint(equalTo: childCountView.bottomAnchor)
        )
        constraints.append(childLabel.leadingAnchor.constraint(equalTo: childCountView.leadingAnchor)
        )
        constraints.append(childLabel.trailingAnchor.constraint(equalTo: childCountView.trailingAnchor, constant: -5)
        )
        constraints.append(childLabel.heightAnchor.constraint(equalTo: childCountView.heightAnchor)
        )
        
        NSLayoutConstraint.activate(constraints)
    }
    //MARK: Small functions
    private func config(comment: String, author: String, isCollapsed: Bool , childrenCount count: Int, image: UIImage? ){
        
        commentLabel.text = comment
        
        authorLabel.text = author
        childLabel.text = isCollapsed ? "X" : "\(count)"
        childCountView.isHidden = count == 0 ? true : false
        
        childLabel.layer.cornerRadius = 5
        childLabel.layer.masksToBounds = true
        
        if comment.isEmpty {
            commentImage.removeFromSuperview()
        } else {
            commentImage.image = image != nil ? image : ToolBox.placeHolderImg
        }
    }
    private func makeSeparator(amount: Int) -> [UIView] {
        var results: [UIView] = []
        for _ in 0 ..< amount {
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = .gray
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
    private func makeLabel(numberOfLines lines: Int, bgColor: UIColor, inset: UIEdgeInsets,textAlignment alignment: NSTextAlignment, textColor: UIColor, font: UIFont) -> PaddingLabel {
        let label = PaddingLabel()
        label.numberOfLines = lines
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = bgColor
        label.text = "Hello World"
        label.inset = inset
        label.textAlignment = alignment
        label.textColor = textColor
        label.font = font
        return label
    }
//    private func detectImageLink(_ string: inout String) -> String? {
//        let links = networkManager.detectLinks(text: string)
//        var urlString = ""
//        links.forEach{
//            if $0.contains(NetWorkManager.baseImgLink) {
//                urlString = $0
//            }
//        }
//        guard !urlString.isEmpty else {
//            return nil
//        }
//        string = string.replacingOccurrences(of: urlString, with: "")
//        urlString = ToolBox.concatStr(string: urlString, size: .mediumThumbnail)
//        return urlString
//    }
//    private func sort(urlString text: String){
//        guard let start = text.lastIndex(of: ".") else {
//            return
//        }
//        let end = text.endIndex
//        let result = text[start..<end]
//        print(result)
//    }
}

