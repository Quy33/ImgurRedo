//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit
import AVKit

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    private var separators: [UIView] = []
    private var networkManager = NetWorkManager()
    private let outerStackViewSpacing: CGFloat = 0
    private let separatorWidth: CGFloat = 15
    
//MARK: Cell UIs
    private var outerStackView = UIStackView()
    private var commentStackView = UIStackView()
    private var headerStackView = UIStackView()
    
    private var authorLabel = PaddingLabel()
    private var childLabel = PaddingLabel()
    private var dateLabel = PaddingLabel()
    private var childCountView = UIView()
    private var bottomSeparator = UIView()
    
    let playerView: PlayerView = {
        let player = PlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        player.backgroundColor = .link
        return player
    }()
    
    private var commentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var commentTextView = UITextView()
//MARK: Cell setup
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, comment: Comment) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        setup(separatorAmount: comment.level, hasImage: comment.hasImageLink, hasVideo: comment.hasVideoLink)
        config(comment)
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
    private func setup(separatorAmount count: Int, hasImage: Bool, hasVideo: Bool) {
        setProperties(count: count)
        addSubViews(hasImage: hasImage, hasVideo: hasVideo)
        setConstraints(hasVideo: hasVideo)
    }
    private func setProperties(count: Int) {
        outerStackView = makeStackView(axis: .horizontal,
                                       distribution: .fill,
                                       color: .lightGray,
                                       spacing: outerStackViewSpacing,
                                       alignment: .center)
        commentStackView = makeStackView(axis: .vertical,
                                         distribution: .fill,
                                         color: .clear,
                                         spacing: 30,
                                         alignment: .center)
        headerStackView = makeStackView(axis: .horizontal,
                                        distribution: .fill,
                                        color: .clear,
                                        spacing: 10,
                                        alignment: .center)
        
        if let container = makeUIView(amount: 1, color: .clear).first {
            childCountView = container
        }
        if let container = makeUIView(amount: 1, color: .darkGray).first {
            bottomSeparator = container
        }
        
        let authorInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        let childLabelInset: UIEdgeInsets = .zero
        let commentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let dateInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        let normalFont: UIFont = .systemFont(ofSize: 17)
        let authorFont: UIFont = .systemFont(ofSize: 15, weight: .light)
        
        authorLabel = makeLabel(numberOfLines: 0,
                                bgColor: .clear,
                                inset: authorInset,
                                textAlignment: .left,
                                textColor: .black,
                                font: authorFont,
                                lineBreak: .byCharWrapping)
        authorLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        childLabel = makeLabel(numberOfLines: 1,
                               bgColor: .link,
                               inset: childLabelInset,
                               textAlignment: .center,
                               textColor: .white,
                               font: normalFont,
                               lineBreak: .byWordWrapping)
        dateLabel = makeLabel(numberOfLines: 1,
                              bgColor: .clear,
                              inset: dateInset,
                              textAlignment: .right,
                              textColor: .black,
                              font: authorFont,
                              lineBreak: .byWordWrapping)
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        separators = makeUIView(amount: count, color: .darkGray)
        
        let attributes: [NSAttributedString.Key:Any] = [
            .foregroundColor: UIColor.purple,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        commentTextView = makeTextView(font: normalFont, bgColor: .clear, scrollable: false, textInset: commentInset, linkAttr: attributes)
        
    }
    private func addSubViews(hasImage: Bool, hasVideo: Bool) {
        contentView.addSubview(outerStackView)
                
        separators.forEach{ outerStackView.addArrangedSubview($0) }
        outerStackView.addArrangedSubview(commentStackView)
        
        commentStackView.addArrangedSubview(headerStackView)
        
        if hasImage {
            commentStackView.addArrangedSubview(commentImage)
        } else {
            if hasVideo {
                commentStackView.addArrangedSubview(playerView)
            }
        }
        
        commentStackView.addArrangedSubview(commentTextView)
        commentStackView.addArrangedSubview(bottomSeparator)
        
        headerStackView.addArrangedSubview(authorLabel)
        headerStackView.addArrangedSubview(dateLabel)
        headerStackView.addArrangedSubview(childCountView)
        childCountView.addSubview(childLabel)
    }
    private func setConstraints(hasVideo: Bool) {
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
            constraints.append($0.widthAnchor.constraint(equalToConstant: separatorWidth))
            constraints.append($0.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
        }
        
        //Comment Stack View
        constraints.append(commentStackView.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
        
        constraints.append(commentTextView.widthAnchor.constraint(equalTo:  commentStackView.widthAnchor))
        
        if hasVideo {
            constraints.append(playerView.widthAnchor.constraint(equalTo: commentStackView.widthAnchor)
            )
            constraints.append(playerView.heightAnchor.constraint(equalToConstant: 200)
            )
        }
        
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
        
        constraints.append(dateLabel.topAnchor.constraint(equalTo: headerStackView.topAnchor)
        )
        constraints.append(dateLabel.bottomAnchor.constraint(equalTo: headerStackView.bottomAnchor)
        )
        constraints.append(dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40))
        
        constraints.append(childCountView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor))
        constraints.append(childCountView.widthAnchor.constraint(equalToConstant: 50))
        
        constraints.append(childLabel.topAnchor.constraint(equalTo: childCountView.topAnchor, constant: 10)
        )
        constraints.append(childLabel.bottomAnchor.constraint(equalTo: childCountView.bottomAnchor)
        )
        constraints.append(childLabel.leadingAnchor.constraint(equalTo: childCountView.leadingAnchor)
        )
        constraints.append(childLabel.trailingAnchor.constraint(equalTo: childCountView.trailingAnchor, constant: -10)
        )
        
        NSLayoutConstraint.activate(constraints)
    }
    //MARK: Small functions
    private func config(_ comment: Comment){
        if comment.value.isEmpty {
            commentTextView.removeFromSuperview()
        }
        if comment.children.isEmpty {
            childCountView.removeFromSuperview()
        }
        
        commentTextView.text = comment.value
        authorLabel.text = comment.author
        dateLabel.text = comment.dateString
        
        if comment.children.isEmpty {
            dateLabel.inset.right = 10
        }
        
        childLabel.text = comment.isCollapsed ? "X" : "\(comment.children.count)"
        childLabel.layer.cornerRadius = 5
        childLabel.layer.masksToBounds = true
        
        commentImage.image = comment.image ?? ToolBox.placeHolderImg

        if let image = comment.image {
            calculateThenSetImage(image)
        }
    }
    private func makeUIView(amount: Int, color: UIColor) -> [UIView] {
        var results: [UIView] = []
        for _ in 0 ..< amount {
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = color
            results.append(separator)
        }
        return results
    }
    private func makeStackView(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, color: UIColor, spacing: CGFloat, alignment: UIStackView.Alignment) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = color
        
        return stackView
    }
    private func makeLabel(numberOfLines lines: Int, bgColor: UIColor, inset: UIEdgeInsets,textAlignment alignment: NSTextAlignment, textColor: UIColor, font: UIFont, lineBreak: NSLineBreakMode) -> PaddingLabel {
        let label = PaddingLabel()
        label.numberOfLines = lines
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = bgColor
        label.text = "Hello World"
        label.inset = inset
        label.textAlignment = alignment
        label.textColor = textColor
        label.font = font
        label.lineBreakMode = lineBreak
        return label
    }

    private func calculateThenSetImage(_ image: UIImage) {
        let screen = UIScreen.main.bounds
        let separatorAmount = CGFloat(separators.count)
        let padding = 10
        let insetWidth = screen.width - (separatorWidth * separatorAmount) - CGFloat(padding * 2)
        let imageRect = ToolBox.calculateImageRatio(image, frameWidth: insetWidth)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(commentImage.widthAnchor.constraint(equalToConstant: imageRect.width)
        )
        constraints.append(commentImage.heightAnchor.constraint(equalToConstant: imageRect.height)
        )
        
        NSLayoutConstraint.activate(constraints)
    }
    private func makeTextView(font: UIFont, bgColor: UIColor, scrollable: Bool, textInset: UIEdgeInsets,linkAttr attributes: [NSAttributedString.Key : Any]?) -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.font = font
        textView.backgroundColor = bgColor
        textView.isScrollEnabled = scrollable
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = textInset
        
        if let attributes = attributes {
            textView.linkTextAttributes = attributes
        }
        
        return textView
    }
}

