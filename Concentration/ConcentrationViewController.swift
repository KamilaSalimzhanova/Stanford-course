//
//  ConcentrationViewController.swift
//  Concentration
//
//  Created by kamila on 31.01.2026.
//

import UIKit

class ConcentrationViewController: UIViewController {
    lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Concentration"
        label.textColor = .orange
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private var flipCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Flips: 0"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private var cloudShapeLayer: CAShapeLayer?
    private let flipCountContainer = UIView()
    
    private var flipCount = 0 {
        didSet {
            flipCountLabel.text = "Flips: \(flipCount)"
        }
    }
    private var cardButtons: [UIButton] = []
    private var emojiDictionary: [Int: String] = [:]
    private var emojis = ["🌟", "🎃", "🏆", "🙂", "🤩", "🥸", "💪🏼", "🎄"]
    private let cardWidth: CGFloat = 120
    private let cardHeight: CGFloat = 160
    private let spacing: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupSubviews()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutCards()
        drawCloudShape()
    }
    
    private func layoutCards() {
        let totalWidth = cardWidth * 2 + spacing
        let totalHeight = cardHeight * 2 + spacing
        
        let startX = (view.bounds.width - totalWidth) / 2
        let startY = (view.bounds.height - totalHeight) / 2
        
        for (index, card) in cardButtons.enumerated() {
            let row = index / 2
            let column = index % 2
            
            card.frame = CGRect(
                x: startX + CGFloat(column) * (cardWidth + spacing),
                y: startY + CGFloat(row) * (cardHeight + spacing),
                width: cardWidth,
                height: cardHeight
            )
        }
    }
    
    private func configureCardAppearance(_ card: UIButton) {
        card.backgroundColor = .orange
        card.layer.cornerRadius = 12
        card.setTitle("", for: .normal)
        card.titleLabel?.font = .systemFont(ofSize: 50)
    }
    
    private func drawCloudShape() {
        let width = flipCountContainer.bounds.width
        let height = flipCountContainer.bounds.height
        guard width > 0, height > 0 else { return }

        if cloudShapeLayer == nil {
            cloudShapeLayer = CAShapeLayer()
            flipCountContainer.layer.insertSublayer(cloudShapeLayer!, at: 0)
        }

        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: width * 0.25, y: height * 0.55),
                    radius: height * 0.3, startAngle: .pi*0.5, endAngle: .pi*1.5, clockwise: true)
        path.addArc(withCenter: CGPoint(x: width * 0.5, y: height * 0.35),
                    radius: height * 0.35, startAngle: .pi, endAngle: 0, clockwise: true)
        path.addArc(withCenter: CGPoint(x: width * 0.75, y: height * 0.55),
                    radius: height * 0.3, startAngle: .pi*1.5, endAngle: .pi*0.5, clockwise: true)
        path.close()

        cloudShapeLayer?.path = path.cgPath
        cloudShapeLayer?.fillColor = UIColor(white: 0.9, alpha: 1).cgColor
    }
}

// MARK: - Setup view
private extension ConcentrationViewController {
    private func setupView() {
        view.backgroundColor = .black
    }
    
    private func setupSubviews() {
        flipCountContainer.translatesAutoresizingMaskIntoConstraints = false
        flipCountContainer.backgroundColor = .clear
        
        setupCardsButtons()
        flipCountContainer.addSubview(flipCountLabel)
        [titleLabel, flipCountContainer].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            flipCountContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flipCountContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            flipCountContainer.widthAnchor.constraint(equalToConstant: 200),
            flipCountContainer.heightAnchor.constraint(equalToConstant: 100),
            
            flipCountLabel.centerXAnchor.constraint(equalTo: flipCountContainer.centerXAnchor),
            flipCountLabel.centerYAnchor.constraint(equalTo: flipCountContainer.centerYAnchor)
        ])
    }
    
    private func setupCardsButtons() {
        for index in 0..<4 {
            let button = UIButton(type: .system)
            button.tag = index
            
            configureCardAppearance(button)
            button.addTarget(self, action: #selector(touchCard(_:)), for: .touchUpInside)
            
            view.addSubview(button)
            cardButtons.append(button)
        }
    }
}

// MARK: - Actions
private extension ConcentrationViewController {
    @objc private func touchCard(_ button: UIButton) {
        flipCount += 1
        game.chooseCard(at: button.tag)
        updateViewFromModel()
    }
    
    private func showCard(_ card: UIButton, emoji: String) {
        card.backgroundColor = .white
        card.setTitle(emoji, for: .normal)
    }
    
    private func hideCard(_ card: UIButton, isMatched: Bool) {
        card.backgroundColor = isMatched ? .clear : .orange
        card.setTitle("", for: .normal)
    }
}

// MARK: - Delegate methods
private extension ConcentrationViewController {
    func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game[safe: index]
            
            if let card {
                card.isFaceUp ? showCard(button, emoji: emoji(for: card)) : hideCard(button, isMatched: card.isMatched)
            }
        }
    }
    
    private func emoji(for card: Card) -> String {
        if emojiDictionary[card.identifier] == nil, emojis.count > 0 {
            let randomUnix = Int(arc4random_uniform(UInt32(emojis.count)))
            emojiDictionary[card.identifier] = emojis.remove(at: randomUnix)
        }
        
        return emojiDictionary[card.identifier] ?? ""
    }
}
