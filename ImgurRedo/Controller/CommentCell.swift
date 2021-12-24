//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit
import AVKit

class CommentCell: UITableViewCell {

//    static let identifier = "CommentCell"
//    private var separators: [UIView] = []
//    private var networkManager = NetWorkManager()
//    private let outerStackViewSpacing: CGFloat = 0
//    private let separatorWidth: CGFloat = 15
//    private var comment = Comment()
////MARK: Cell UIs
//    private var outerStackView = UIStackView()
//    private var commentStackView = UIStackView()
//    private var headerStackView = UIStackView()
//
//    private var authorLabel = PaddingLabel()
//    private var childLabel = PaddingLabel()
//    private var dateLabel = PaddingLabel()
//    private var childCountView = UIView()
//    private var bottomSeparator = UIView()
//
//    private var commentImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    var commentPlayerView: BasicPlayerView = {
//        let view = BasicPlayerView()
//
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .link
//        if let layer = view.layer as? AVPlayerLayer {
//            layer.videoGravity = .resizeAspect
//        }
//
//        return view
//    }()
//
//    private var commentTextView = UITextView()
//
////MARK: Cell setup
//    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, comment: Comment) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.backgroundColor = .clear
//        self.comment = comment
//        setup()
//        config()
//    }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    //MARK: Comment Setup
//    private func setup() {
//        setProperties()
//        addSubViews()
//        setConstraints()
//    }
//    private func setProperties() {
//        outerStackView = makeStackView(axis: .horizontal,
//                                       distribution: .fill,
//                                       color: .lightGray,
//                                       spacing: outerStackViewSpacing,
//                                       alignment: .center)
//        commentStackView = makeStackView(axis: .vertical,
//                                         distribution: .fill,
//                                         color: .clear,
//                                         spacing: 30,
//                                         alignment: .center)
//        headerStackView = makeStackView(axis: .horizontal,
//                                        distribution: .fill,
//                                        color: .clear,
//                                        spacing: 10,
//                                        alignment: .center)
//
//        if let container = makeUIView(amount: 1, color: .clear).first {
//            childCountView = container
//        }
//        if let container = makeUIView(amount: 1, color: .darkGray).first {
//            bottomSeparator = container
//        }
//
//        let authorInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
//        let childLabelInset: UIEdgeInsets = .zero
//        let commentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        let dateInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//
//        let normalFont: UIFont = .systemFont(ofSize: 17)
//        let authorFont: UIFont = .systemFont(ofSize: 15, weight: .light)
//
//        authorLabel = makeLabel(numberOfLines: 0,
//                                bgColor: .clear,
//                                inset: authorInset,
//                                textAlignment: .left,
//                                textColor: .black,
//                                font: authorFont,
//                                lineBreak: .byCharWrapping)
//        authorLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//
//        childLabel = makeLabel(numberOfLines: 1,
//                               bgColor: .link,
//                               inset: childLabelInset,
//                               textAlignment: .center,
//                               textColor: .white,
//                               font: normalFont,
//                               lineBreak: .byWordWrapping)
//        dateLabel = makeLabel(numberOfLines: 1,
//                              bgColor: .clear,
//                              inset: dateInset,
//                              textAlignment: .right,
//                              textColor: .black,
//                              font: authorFont,
//                              lineBreak: .byWordWrapping)
//        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//
//        separators = makeUIView(amount: comment.level, color: .darkGray)
//
//        let attributes: [NSAttributedString.Key:Any] = [
//            .foregroundColor: UIColor.purple,
//            .underlineStyle: NSUnderlineStyle.single.rawValue
//        ]
//
//        commentTextView = makeTextView(font: normalFont, bgColor: .clear, scrollable: false, textInset: commentInset, linkAttr: attributes)
//
//    }
//    private func addSubViews() {
//        contentView.addSubview(outerStackView)
//
//        separators.forEach{ outerStackView.addArrangedSubview($0) }
//        outerStackView.addArrangedSubview(commentStackView)
//
//        commentStackView.addArrangedSubview(headerStackView)
//
//        if comment.hasImageLink {
//            commentStackView.addArrangedSubview(commentImage)
//        } else if comment.hasVideoLink {
//            commentStackView.addArrangedSubview(commentPlayerView)
//        }
//
//        commentStackView.addArrangedSubview(commentTextView)
//        commentStackView.addArrangedSubview(bottomSeparator)
//
//        headerStackView.addArrangedSubview(authorLabel)
//        headerStackView.addArrangedSubview(dateLabel)
//        headerStackView.addArrangedSubview(childCountView)
//        childCountView.addSubview(childLabel)
//    }
//    private func setConstraints() {
//        var constraints: [NSLayoutConstraint] = []
//
//        //Outer Stack View
//        constraints.append(outerStackView.topAnchor.constraint(
//            equalTo: contentView.topAnchor)
//        )
//        constraints.append(outerStackView.bottomAnchor.constraint(
//            equalTo: contentView.bottomAnchor)
//        )
//        constraints.append(outerStackView.leadingAnchor.constraint(
//            equalTo: contentView.leadingAnchor, constant: 0)
//        )
//        constraints.append(outerStackView.trailingAnchor.constraint(
//            equalTo: contentView.trailingAnchor, constant: 0)
//        )
//
//        separators.forEach {
//            constraints.append($0.widthAnchor.constraint(equalToConstant: separatorWidth))
//            constraints.append($0.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
//        }
//
//        //Comment Stack View
//        constraints.append(commentStackView.heightAnchor.constraint(equalTo: outerStackView.heightAnchor))
//
//        constraints.append(commentTextView.widthAnchor.constraint(equalTo:  commentStackView.widthAnchor))
//
//        //Bottom of Comment Stack View
//        constraints.append(bottomSeparator.widthAnchor.constraint(equalTo: commentStackView.widthAnchor)
//        )
//        constraints.append(bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
//        )
//        if comment.hasVideoLink {
////            constraints.append(commentPlayerView.widthAnchor.constraint(equalTo: commentStackView.widthAnchor)
////            )
////            constraints.append(commentPlayerView.heightAnchor.constraint(equalToConstant: 200)
////            )
//        }
//
//        //Header Stack View
//        constraints.append(headerStackView.widthAnchor.constraint(equalTo: commentStackView.widthAnchor)
//        )
//
//        constraints.append(authorLabel.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor)
//        )
//        constraints.append(authorLabel.topAnchor.constraint(equalTo: headerStackView.topAnchor)
//        )
//        constraints.append(authorLabel.bottomAnchor.constraint(equalTo: headerStackView.bottomAnchor)
//        )
//
//        constraints.append(dateLabel.topAnchor.constraint(equalTo: headerStackView.topAnchor)
//        )
//        constraints.append(dateLabel.bottomAnchor.constraint(equalTo: headerStackView.bottomAnchor)
//        )
//        constraints.append(dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40))
//
//        constraints.append(childCountView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor))
//        constraints.append(childCountView.widthAnchor.constraint(equalToConstant: 50))
//
//        constraints.append(childLabel.topAnchor.constraint(equalTo: childCountView.topAnchor, constant: 10)
//        )
//        constraints.append(childLabel.bottomAnchor.constraint(equalTo: childCountView.bottomAnchor)
//        )
//        constraints.append(childLabel.leadingAnchor.constraint(equalTo: childCountView.leadingAnchor)
//        )
//        constraints.append(childLabel.trailingAnchor.constraint(equalTo: childCountView.trailingAnchor, constant: -10)
//        )
//
//        NSLayoutConstraint.activate(constraints)
//    }
//    //MARK: Small functions
//    private func config(){
//        if comment.value.isEmpty {
//            commentTextView.removeFromSuperview()
//        }
//        if comment.children.isEmpty {
//            childCountView.removeFromSuperview()
//        }
//
//        commentTextView.text = comment.value
//        authorLabel.text = comment.author
//        dateLabel.text = comment.dateString
//
//        if comment.children.isEmpty {
//            dateLabel.inset.right = 10
//        }
//
//        childLabel.text = comment.isCollapsed ? "X" : "\(comment.children.count)"
//        childLabel.layer.cornerRadius = 5
//        childLabel.layer.masksToBounds = true
//
//        commentImage.image = comment.image ?? ToolBox.placeHolderImg
//
//        if let image = comment.image {
//            let imageRect = calculateMediaFrame(image.size)
//            commentImage.widthAnchor.constraint(equalToConstant: imageRect.width).isActive = true
//            commentImage.heightAnchor.constraint(equalToConstant: imageRect.height).isActive = true
//        } else if comment.hasVideoLink {
//            commentPlayerView.setupPlayer(comment.videoLink!)
//            let videoRect = calculateMediaFrame(commentPlayerView.videoSize ?? CGSize.zero)
//            commentPlayerView.widthAnchor.constraint(equalToConstant: videoRect.width).isActive = true
//            commentPlayerView.heightAnchor.constraint(equalToConstant: videoRect.height).isActive = true
//        }
//    }
//    func updateCollapsed(isCollapsed: Bool, count: Int) {
//        childLabel.text = isCollapsed ? "X" : "\(count)"
//    }
//
//    private func makeUIView(amount: Int, color: UIColor) -> [UIView] {
//        var results: [UIView] = []
//        for _ in 0 ..< amount {
//            let separator = UIView()
//            separator.translatesAutoresizingMaskIntoConstraints = false
//            separator.backgroundColor = color
//            results.append(separator)
//        }
//        return results
//    }
//    private func makeStackView(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, color: UIColor, spacing: CGFloat, alignment: UIStackView.Alignment) -> UIStackView {
//        let stackView = UIStackView()
//        stackView.axis = axis
//        stackView.spacing = spacing
//        stackView.distribution = distribution
//        stackView.alignment = alignment
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.backgroundColor = color
//
//        return stackView
//    }
//    private func makeLabel(numberOfLines lines: Int, bgColor: UIColor, inset: UIEdgeInsets,textAlignment alignment: NSTextAlignment, textColor: UIColor, font: UIFont, lineBreak: NSLineBreakMode) -> PaddingLabel {
//        let label = PaddingLabel()
//        label.numberOfLines = lines
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = bgColor
//        label.text = "Hello World"
//        label.inset = inset
//        label.textAlignment = alignment
//        label.textColor = textColor
//        label.font = font
//        label.lineBreakMode = lineBreak
//        return label
//    }
//
//    private func calculateMediaFrame(_ size: CGSize) -> CGRect {
//        let screen = UIScreen.main.bounds
//        let separatorAmount = CGFloat(separators.count)
//        let padding = 10
//        let insetWidth = screen.width - (separatorWidth * separatorAmount) - CGFloat(padding * 2)
//        let imageRect = ToolBox.calculateMediaRatio(size, frameWidth: insetWidth)
//        return imageRect
//    }
//    private func makeTextView(font: UIFont, bgColor: UIColor, scrollable: Bool, textInset: UIEdgeInsets,linkAttr attributes: [NSAttributedString.Key : Any]?) -> UITextView {
//        let textView = UITextView()
//        textView.translatesAutoresizingMaskIntoConstraints = false
//
//        textView.font = font
//        textView.backgroundColor = bgColor
//        textView.isScrollEnabled = scrollable
//        textView.isEditable = false
//        textView.dataDetectorTypes = .link
//        textView.textContainerInset = textInset
//
//        if let attributes = attributes {
//            textView.linkTextAttributes = attributes
//        }
//
//        return textView
//    }
//    func play(){
//        commentPlayerView.play()
//    }
//    func pause() {
//        commentPlayerView.pause()
//    }
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
}

