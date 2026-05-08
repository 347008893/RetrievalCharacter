import UIKit

class ViewController: UIViewController {
    private let textView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.attributedText = NSAttributedString(string: String(
            repeating: "translatesAutoresizingMaskIntoConstraints",
            count: 100
        ))
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let drawableView = DrawableView()

    private let retrievalButton = {
        let button = UIButton(type: .custom)
        button.setTitle("retrieve", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        makeUI()
        retrievalButton.addTarget(self, action: #selector(retrieve), for: .touchUpInside)
    }

    private func makeUI() {
        view.addSubview(textView)
        view.addSubview(drawableView)
        view.addSubview(retrievalButton)

        drawableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),

            drawableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            drawableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            retrievalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            retrievalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            retrievalButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            retrievalButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func retrieve() {
        let labelSize = textView.bounds.size
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: labelSize)
        let textStorage = NSTextStorage(attributedString: textView.attributedText!)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0

        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )

        let path = drawableView.selectedPath()
        let rect = drawableView.selectedRect()
        let fixedRect = rect.offsetBy(dx: -textContainerOffset.x, dy: -textContainerOffset.y)
        print(rect, fixedRect)
        let glyphRange = layoutManager.glyphRange(
            forBoundingRectWithoutAdditionalLayout: fixedRect,
            in: textContainer
        )

        var selectedCharRange: [NSRange] = []
        for item in 0...glyphRange.length {
            let glyphIndex = item + glyphRange.location
            let lineFragmentRect = layoutManager.lineFragmentRect(
                forGlyphAt: glyphIndex,
                effectiveRange: nil
            )
            let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)
            let actualPoint = CGPoint(
                x: lineFragmentRect.origin.x + glyphLocation.x + textContainerOffset.x,
                y: lineFragmentRect.origin.y + glyphLocation.y + textContainerOffset.y
            )
            if path.contains(actualPoint) {
                let characterRange = layoutManager.characterRange(
                    forGlyphRange: NSRange(location: glyphIndex, length: 1),
                    actualGlyphRange: nil
                )
                print(characterRange)
                selectedCharRange.append(characterRange)
            }
        }

        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        for item in selectedCharRange {
            attributedText.addAttributes([.foregroundColor: UIColor.red], range: item)
        }
        textView.attributedText = attributedText
    }
}
