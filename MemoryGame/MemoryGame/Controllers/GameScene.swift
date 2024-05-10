//
//  GameScene.swift
//  MemoryGame
//
//  Created by Alexandr Filovets on 30.04.24.
//
import GameplayKit
import SpriteKit

struct CardItem: Equatable {
    let id: String
    let image: String

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }

    static func mockData() -> [CardItem] {
        [
            CardItem(id: "1", image: "card1"),
            CardItem(id: "2", image: "card2"),
            CardItem(id: "3", image: "card3"),
            CardItem(id: "4", image: "card4"),
            CardItem(id: "5", image: "card5"),
            CardItem(id: "6", image: "card6"),
            CardItem(id: "7", image: "card7"),
            CardItem(id: "8", image: "card8")
        ]
    }
}

final class GameScene: SKScene {
    // SpriteNode
    var movesTitleLabel: SKLabelNode!
    private var pauseLabel: SKLabelNode?
    private var leftImage: SKSpriteNode!
    private var refreshImage: SKSpriteNode!
    private var pauseImage: SKSpriteNode!
    private var youWinImage: SKSpriteNode!
    private var movesLabel: SKLabelNode!
    private var timeTitleLabel: SKLabelNode!
    private var rectangleSettingsImage: SKSpriteNode!
    
    // Buttons
    var refreshWin: UIButton!
    private var menuWin: UIButton!
    private var settingsImage: UIButton!
    private var play: UIButton!
    private var sound: UIButton!
    private var vibro: UIButton!
    
    // Bool
    private var isGamePaused = false
    private var isSoundEnabled = true
    private var isVibrationEnabled = true

    // cards
    var matchedCardsCount = 0
    var movesCount = 0
    var matchedCards: [Card] = []
    var openCards: [Card] = []
    private var cardData = CardItem.mockData()
    private var cards: [Card] = []
    private let numberOfCards = 16
    private let numberOfCardsInRow = 4
    private let numberOfCardsInColumn = 4
    private var startTime: Date?
    
    override func didMove(to view: SKView) {
        let cardRatio: CGFloat = 0.2 // Отношение размера карточки к размеру экрана
        let cardSize = CGSize(width: size.width * cardRatio, height: size.width * cardRatio)
        
        let totalWidth = cardSize.width * CGFloat(numberOfCardsInRow)
        let totalHeight = cardSize.height * CGFloat(numberOfCardsInColumn)
        
        let startX = (size.width - totalWidth) / 2
        let startY = (size.height - totalHeight) / 2
        
        let horizontalSpacing = (size.width - totalWidth) / CGFloat(numberOfCardsInRow - 1) // Горизонтальный отступ между карточками
        
        var cardsDataCopy = cardData + cardData
        cardsDataCopy.shuffle()
        
        for i in 0 ..< numberOfCards {
            let cardImageName = cardsDataCopy[i]
            let frontTexture = SKTexture(imageNamed: cardImageName.image)
            let backTexture = SKTexture(imageNamed: "card_back")
            
            let card = Card(frontTexture: frontTexture, backTexture: backTexture, imageName: cardImageName.image)
            card.size = cardSize
            let column = i % numberOfCardsInRow
            let x = startX + (cardSize.width + horizontalSpacing) * CGFloat(column)
            let row = i / numberOfCardsInRow
            let y = startY + (cardSize.height + 10) * CGFloat(row)
            card.position = CGPoint(x: x, y: y)
            addChild(card)
            cards.append(card)
        }
        
        let backgroundImage = SKSpriteNode(imageNamed: "bg_game")
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundImage.size = CGSize(width: size.width, height: size.height)
        backgroundImage.zPosition = -1
        backgroundImage.texture?.filteringMode = .nearest
        backgroundImage.texture?.usesMipmaps = false
        backgroundImage.texture?.preload(completionHandler: {})
        addChild(backgroundImage)
        
        pauseLabel = SKLabelNode(text: "Pause Game")
        pauseLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseLabel?.fontSize = 60
        pauseLabel?.fontColor = UIColor.white.withAlphaComponent(0.5)
        pauseLabel?.isHidden = true
        addChild(pauseLabel!)
        
        let rectangleImage = SKSpriteNode(imageNamed: "rectangle")
        rectangleImage.position = CGPoint(x: size.width / 2, y: startY + cardSize.height + 270)
        rectangleImage.size = CGSize(width: size.width, height: 60)
        rectangleImage.zPosition = 1
        addChild(rectangleImage)
        
        settingsImage = UIButton(type: .custom)
        settingsImage.setImage(UIImage(named: "settings"), for: .normal)
        settingsImage.frame = CGRect(x: size.width / 2 - 192, y: startY + cardSize.height - 220, width: 60, height: 60)
        settingsImage.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsImage.isUserInteractionEnabled = true
        view.addSubview(settingsImage)
        
        pauseImage = SKSpriteNode(imageNamed: "pause")
        pauseImage.position = CGPoint(x: size.width / 2 - 155, y: startY + cardSize.height - 220)
        pauseImage.size = CGSize(width: 60, height: 60)
        addChild(pauseImage)
        
        leftImage = SKSpriteNode(imageNamed: "left")
        leftImage.position = CGPoint(x: size.width / 2, y: startY + cardSize.height - 220)
        leftImage.size = CGSize(width: 60, height: 60)
        addChild(leftImage)
        
        refreshImage = SKSpriteNode(imageNamed: "refresh")
        refreshImage.position = CGPoint(x: size.width / 2 + 155, y: startY + cardSize.height - 220)
        refreshImage.size = CGSize(width: 60, height: 60)
        addChild(refreshImage)
        
        movesTitleLabel = SKLabelNode(fontNamed: "Bold")
        movesTitleLabel.fontSize = 22
        movesTitleLabel.text = "MOVIES: \(movesCount)"
        movesTitleLabel.horizontalAlignmentMode = .left
        movesTitleLabel.verticalAlignmentMode = .center
        movesTitleLabel.position = CGPoint(x: -rectangleImage.size.width / 2 + movesTitleLabel.frame.width / 2 - 30, y: 0)
        rectangleImage.addChild(movesTitleLabel)
        
        timeTitleLabel = SKLabelNode(fontNamed: "Bold")
        timeTitleLabel.fontSize = 22
        timeTitleLabel.position = CGPoint(x: rectangleImage.size.width / 2 - 20, y: 0)
        timeTitleLabel.horizontalAlignmentMode = .right
        timeTitleLabel.verticalAlignmentMode = .center
        rectangleImage.addChild(timeTitleLabel)
        
        startGame()
    }
    
    private func startGame() {
        movesCount = 0
        startTime = Date()
        for card in cards {
            card.isMatched = false
            card.isUserInteractionEnabled = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) { updateTimer() }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(startTime)
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        timeTitleLabel.text = "TIME: \(timeString)"
    }
    
    func endGame() {
        for card in cards { card.isUserInteractionEnabled = false }
        
        // Приостанавливаем игру
        isGamePaused = true
        isPaused = true
        settingsImage.isHidden = true
        
        // полупрозрачный фон
        let backgroundSprite = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: size)
        backgroundSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundSprite.zPosition = 9
        addChild(backgroundSprite)
        
        // картинка YOU WIN
        youWinImage = SKSpriteNode(imageNamed: "you_win2")
        youWinImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        youWinImage.size = CGSize(width: size.width, height: size.height)
        youWinImage.zPosition = 10
        youWinImage.texture?.filteringMode = .nearest
        youWinImage.texture?.usesMipmaps = false
        youWinImage.texture?.preload(completionHandler: {})
        addChild(youWinImage)
        
        // кнопки на экране завершения игры
        
        refreshWin = UIButton(type: .custom)
        refreshWin.setImage(UIImage(named: "refreshWin"), for: .normal)
        refreshWin.frame = CGRect(x: size.width / 2 - 70, y: size.height / 2 + 240, width: 60, height: 60)
        refreshWin.addTarget(self, action: #selector(refreshWinTapped), for: .touchUpInside)
        refreshWin.isUserInteractionEnabled = true
        view?.addSubview(refreshWin)
        
        menuWin = UIButton(type: .custom)
        menuWin.setImage(UIImage(named: "menuWin"), for: .normal)
        menuWin.frame = CGRect(x: size.width / 2 + 10, y: size.height / 2 + 240, width: 60, height: 60)
        menuWin.addTarget(self, action: #selector(menuWinTapped), for: .touchUpInside)
        menuWin.isUserInteractionEnabled = true
        view?.addSubview(menuWin)
        
        // Отображаем количество ходов и время игры
        let movesLabel = SKLabelNode(text: "Moves: \(movesCount)")
        movesLabel.fontSize = 30
        movesLabel.zPosition = 12
        movesLabel.fontColor = UIColor.white
        movesLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 160)
        addChild(movesLabel)
        
        guard let startTime = startTime else { return }
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(startTime)
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        let timeLabel = SKLabelNode(text: "Time: \(timeString)")
        timeLabel.fontSize = 30
        timeLabel.zPosition = 12
        timeLabel.fontColor = UIColor.white
        timeLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 200)
        addChild(timeLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == refreshImage {
                let scene = GameScene(size: self.size)
                scene.scaleMode = self.scaleMode
                self.view?.presentScene(scene)
            } else if touchedNode == pauseImage {
                if isGamePaused {
                    // Возобновить игру
                    isPaused = false
                    isGamePaused = false
                    pauseLabel?.isHidden = true
                } else {
                    // Остановить игру
                    isPaused = true
                    isGamePaused = true
                    pauseLabel?.isHidden = false
                }
            }
            if touchedNode == refreshImage {
                let scene = GameScene(size: self.size)
                scene.scaleMode = self.scaleMode
                self.view?.presentScene(scene)
            }
            if touchedNode == leftImage {
                let viewController = self.view?.window?.rootViewController
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc private func refreshWinTapped() {
        refreshWin.isHidden = true
        menuWin.isHidden = true
        let scene = GameScene(size: self.size)
        scene.scaleMode = self.scaleMode
        self.view?.presentScene(scene)
    }

    @objc private func menuWinTapped() {
        let viewController = self.view?.window?.rootViewController
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func settingsTapped() {
        isUserInteractionEnabled = false
        settingsImage.isUserInteractionEnabled = false

        // Приостанавливаем игру
        isGamePaused = true
        isPaused = true

        rectangleSettingsImage = SKSpriteNode(imageNamed: "settings_window")
        rectangleSettingsImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        rectangleSettingsImage.size = CGSize(width: 300, height: 200)
        rectangleSettingsImage.zPosition = 13
        rectangleSettingsImage.texture?.filteringMode = .nearest
        rectangleSettingsImage.texture?.usesMipmaps = false
        rectangleSettingsImage.texture?.preload(completionHandler: {})
        addChild(rectangleSettingsImage)

        play = UIButton(type: .custom)
        play.setImage(UIImage(named: "play"), for: .normal)
        play.frame = CGRect(x: size.width / 2 + 60, y: size.height / 2 - 26, width: 60, height: 60)
        play.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        play.isUserInteractionEnabled = true
        view?.addSubview(play)

        sound = UIButton(type: .custom)
        sound.frame = CGRect(x: size.width / 2 - 30, y: size.height / 2 - 26, width: 60, height: 60)
        sound.addTarget(self, action: #selector(soundTapped), for: .touchUpInside)
        sound.isUserInteractionEnabled = true
        view?.addSubview(sound)

        vibro = UIButton(type: .custom)
        vibro.frame = CGRect(x: size.width / 2 - 120, y: size.height / 2 - 26, width: 60, height: 60)
        vibro.addTarget(self, action: #selector(vibroTapped), for: .touchUpInside)
        vibro.isUserInteractionEnabled = true
        view?.addSubview(vibro)

        // Восстановление состояний звука и вибрации из UserDefaults
        isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled")
        isVibrationEnabled = UserDefaults.standard.bool(forKey: "isVibrationEnabled")

        // Установка изображений для кнопок "Sound" и "Vibro" в соответствии с состояниями
        sound.setImage(UIImage(named: isSoundEnabled ? "soundOn" : "soundOff"), for: .normal)
        vibro.setImage(UIImage(named: isVibrationEnabled ? "vibroOn" : "vibroOff"), for: .normal)
    }
    
    @objc private func playTapped() {
        settingsImage.isUserInteractionEnabled = true
        rectangleSettingsImage.isHidden = true
        isUserInteractionEnabled = true
        play.isHidden = true
        sound.isHidden = true
        vibro.isHidden = true
        
        // Сохраняем состояния звука и вибрации в UserDefaults
        UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        UserDefaults.standard.set(isVibrationEnabled, forKey: "isVibrationEnabled")
        
        // Продолжаем игру
        isGamePaused = false
        isPaused = false
    }
    
    @objc private func soundTapped() {
        if isSoundEnabled {
            // Звук включен, отключаем его
            sound.setImage(UIImage(named: "soundOff"), for: .normal)
            isSoundEnabled = false
        } else {
            // Звук выключен, включаем его
            sound.setImage(UIImage(named: "soundOn"), for: .normal)
            isSoundEnabled = true
        }
        // Сохраняем состояние звука в UserDefaults
        UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
    }

    @objc private func vibroTapped() {
        if isVibrationEnabled {
            // Вибрация включена, отключаем ее
            vibro.setImage(UIImage(named: "vibroOff"), for: .normal)
            isVibrationEnabled = false
        } else {
            // Вибрация выключена, включаем ее
            vibro.setImage(UIImage(named: "vibroOn"), for: .normal)
            isVibrationEnabled = true
        }
        // Сохраняем состояние вибрации в UserDefaults
        UserDefaults.standard.set(isVibrationEnabled, forKey: "isVibrationEnabled")
    }
}
