//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit
import AVKit

class CommentCell: UITableViewCell {
//MARK: Variables
    static let identifier = "CommentCell"
    static let barWidth: CGFloat = 2
    static let separatorWidth: CGFloat = 5
    static let outerStvSpacing: CGFloat = 10
//MARK: UI Elements
    private var outerStv = UIStackView()
    private var leftBar = UIView()
    private var commentStv = UIStackView()
    private var commentTextView = UITextView()
    private var bottomSeparator = UIView()
    private var bottomBar = UIView()
    private var upperStv = UIStackView()
    private var userNameLbl = PaddingLabel()
    private var collapseLbl = PaddingLabel()
    private var dateLbl = PaddingLabel()
    private var collapseContainer = UIView()
    private var bottomLeftBar = UIView()
    private var bottomStv = UIStackView()
    private var commentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.image = ToolBox.placeHolderImg
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var playerView: BasicPlayerView = {
        let view = BasicPlayerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
//MARK: Unused Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//MARK: Cell Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setProperties()
        addUiElements()
        setUiConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setProperties() {
        
        let attributes: [NSAttributedString.Key:Any] = [
            .foregroundColor: UIColor.systemPink,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        outerStv = makeStackView (
            axis: .horizontal,
            distribution: .fill,
            color: .darkGray,
            spacing: 0,
            alignment: .center
        )
        commentStv = makeStackView(
            axis: .vertical,
            distribution: .fill,
            color: .black,
            spacing: 0,
            alignment: .center
        )
        upperStv = makeStackView(
            axis: .horizontal,
            distribution: .fill,
            color: .clear,
            spacing: 0,
            alignment: .center
        )
        commentTextView = makeTextView(bgColor: .clear, linkAttr: attributes)
        commentTextView.textColor = .white
        leftBar = makeUIView(color: .lightGray)
        bottomBar = makeUIView(color: .darkGray)
        let smallFont = UIFont.systemFont(ofSize: 15, weight: .light)
        userNameLbl = makeLabel(numberOfLines: 0,bgColor: .clear, textColor: .white, font: smallFont)
        collapseLbl = makeLabel(bgColor: .link, textAlignment: .center, textColor: .white)
        dateLbl = makeLabel(bgColor: .clear, textAlignment: .right, textColor: .white, font: smallFont)
        
        bottomStv = makeStackView(axis: .horizontal, distribution: .fill, color: .clear, spacing: 0, alignment: .center)
        bottomLeftBar = makeUIView(color: .lightGray)
        bottomBar = makeUIView(color: .darkGray)
        bottomSeparator = makeUIView(color: .clear)
    }
    
    private func addUiElements() {
        //<ContentView SubView>
        contentView.addSubview(outerStv)
            //<OuterStv ArrangedSubView>
            outerStv.addArrangedSubview(leftBar)
            outerStv.addArrangedSubview(commentStv)
                //<CommentStv ArrangedSubView>
                commentStv.addArrangedSubview(upperStv)
                    //<UpperStv ArrangedSubView>
                    upperStv.addArrangedSubview(userNameLbl)
                    upperStv.addArrangedSubview(collapseContainer)
                    //</UpperStv ArrangedSubView>
                collapseContainer.addSubview(collapseLbl)
                commentStv.addArrangedSubview(commentImageView)
                commentStv.addArrangedSubview(playerView)
                commentStv.addArrangedSubview(commentTextView)
                commentStv.addArrangedSubview(dateLbl)
                commentStv.addArrangedSubview(bottomSeparator)
                commentStv.addArrangedSubview(bottomStv)
                    //<BottomStv ArrangedStv>
                    bottomStv.addArrangedSubview(bottomLeftBar)
                    bottomStv.addArrangedSubview(bottomBar)
                    //</BottomStv ArrangedStv>
                //</CommentStv ArrangedSubView>
            //</OuterStv ArrangedSubView>
        //</ContentView SubView>
    }
    
    private func setUiConstraints() {
        var constraints: [NSLayoutConstraint] = []
        //Outer View
        constraints.append(outerStv.topAnchor.constraint(equalTo: contentView.topAnchor)
        )
        constraints.append(outerStv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        )
        constraints.append(outerStv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        )
        constraints.append(outerStv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        )
        //OuterView arranged subView
        constraints.append(leftBar.leadingAnchor.constraint(equalTo: outerStv.leadingAnchor)
        )
        constraints.append(leftBar.topAnchor.constraint(equalTo: outerStv.topAnchor)
        )
        constraints.append(leftBar.bottomAnchor.constraint(equalTo: outerStv.bottomAnchor)
        )
        constraints.append(leftBar.widthAnchor.constraint(equalToConstant: CommentCell.barWidth)
        )
        
        constraints.append(commentStv.trailingAnchor.constraint(equalTo: outerStv.trailingAnchor)
        )
        constraints.append(commentStv.topAnchor.constraint(equalTo: outerStv.topAnchor)
        )
        constraints.append(commentStv.bottomAnchor.constraint(equalTo: outerStv.bottomAnchor)
        )
        //commentStv arranged subView
        constraints.append(commentTextView.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(upperStv.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(upperStv.topAnchor.constraint(equalTo: commentStv.topAnchor)
        )
        constraints.append(commentImageView.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(dateLbl.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(bottomStv.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(bottomStv.bottomAnchor.constraint(equalTo: commentStv.bottomAnchor)
        )
        constraints.append(playerView.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(bottomSeparator.widthAnchor.constraint(equalTo: commentStv.widthAnchor)
        )
        constraints.append(bottomSeparator.heightAnchor.constraint(
            equalToConstant: CommentCell.separatorWidth)
        )
        //bottomStv arranged subview
        constraints.append(bottomBar.heightAnchor.constraint(
            equalToConstant: CommentCell.barWidth)
        )
        constraints.append(bottomBar.trailingAnchor.constraint(
            equalTo: bottomStv.trailingAnchor)
        )
        constraints.append(bottomLeftBar.heightAnchor.constraint(equalToConstant: CommentCell.barWidth)
        )
        constraints.append(bottomLeftBar.widthAnchor.constraint(equalToConstant: CommentCell.barWidth)
        )
        constraints.append(bottomLeftBar.leadingAnchor.constraint(equalTo: bottomStv.leadingAnchor)
        )

        //upperStv arranged subView
        constraints.append(userNameLbl.leadingAnchor.constraint(equalTo: upperStv.leadingAnchor)
        )
        constraints.append(userNameLbl.topAnchor.constraint(equalTo: upperStv.topAnchor)
        )
        constraints.append(userNameLbl.bottomAnchor.constraint(equalTo: upperStv.bottomAnchor)
        )
        constraints.append(collapseContainer.trailingAnchor.constraint(equalTo: upperStv.trailingAnchor)
        )
        constraints.append(collapseContainer.heightAnchor.constraint(equalTo: upperStv.heightAnchor)
        )
        constraints.append(collapseContainer.widthAnchor.constraint(equalToConstant: 50)
        )
        //collapseContainer subView
        constraints.append(collapseLbl.topAnchor.constraint(equalTo: collapseContainer.topAnchor, constant: 5)
        )
        constraints.append(collapseLbl.bottomAnchor.constraint(equalTo: collapseContainer.bottomAnchor, constant: -5)
        )
        constraints.append(collapseLbl.leadingAnchor.constraint(equalTo: collapseContainer.leadingAnchor, constant: 5)
        )
        constraints.append(collapseLbl.trailingAnchor.constraint(equalTo: collapseContainer.trailingAnchor, constant: -5)
        )
        
        NSLayoutConstraint.activate(constraints)
    }
//MARK: Cell Config
    func config(_ comment: Comment) {
        leftBar.isHidden = comment.isTop
        
        let spacing = CGFloat(comment.level) * CommentCell.outerStvSpacing
        outerStv.spacing = spacing
        
        commentTextView.text = comment.value
        commentTextView.isHidden = comment.value.isEmpty
                
        commentImageView.image = comment.imageData?.image ?? ToolBox.placeHolderImg
        commentImageView.isHidden = !comment.hasImageLink

        userNameLbl.text = comment.author
        dateLbl.text = comment.dateString
        
        updateCollapsed(isCollapsed: comment.isCollapsed, count: comment.children.count, isTop: comment.isTop)
        
        playerView.isHidden = !comment.hasVideoLink
        if comment.hasVideoLink {
            playerView.image = comment.videoData?.thumbnail ?? ToolBox.placeHolderImg
            playerView.prepareToPlay(url: comment.videoData!.link, shouldPlayImmediately: true)
        }
    }
    func updateCollapsed(isCollapsed: Bool, count: Int, isTop: Bool){
        collapseLbl.text = isCollapsed ? "X" : "\(count)"
        collapseContainer.isHidden = count == 0 ? true : false
        bottomLeftBar.isHidden = isTop && isCollapsed ? false : true
        
        if !collapseContainer.isHidden {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.collapseLbl.clipsToBounds = true
                strongSelf.collapseLbl.layer.cornerRadius = strongSelf.collapseLbl.frame.height/2
            }
        }
    }

//MARK: Make UI functions
    private func makeLabel(numberOfLines lines: Int = 1,
                           bgColor: UIColor,
                           inset: UIEdgeInsets = .init(top: 2, left: 5, bottom: 2, right: 5),
                           textAlignment alignment: NSTextAlignment = .left,
                           textColor: UIColor = .black,
                           font: UIFont = .systemFont(ofSize: 17),
                           lineBreak: NSLineBreakMode = .byWordWrapping
    ) -> PaddingLabel {
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
    private func makeUIView(color: UIColor) -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = color
        return separator
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
    private func makeTextView(font: UIFont = .systemFont(ofSize: 17),
                              bgColor: UIColor,
                              scrollable: Bool = false,
                              textInset: UIEdgeInsets = .zero,
                              linkAttr attributes: [NSAttributedString.Key : Any]?
    ) -> UITextView {
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
//MARK: PlayerView function
    func play() {
        playerView.play()
    }
    func cleanup() {
        playerView.cleanup()
    }
    func prepareToPlay(url: URL, shouldPlayImmediately: Bool) {
        playerView.prepareToPlay(url: url, shouldPlayImmediately: shouldPlayImmediately)
    }
    func setPlayerViewDelegate(_ delegator: BasicPlayerViewDelegate) {
        playerView.delegate = delegator
    }
}

