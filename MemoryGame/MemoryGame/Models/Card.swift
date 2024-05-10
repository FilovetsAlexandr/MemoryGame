//
//  Card.swift
//  MemoryGame
//
//  Created by Alexandr Filovets on 30.04.24.
//
// модель для игровой карточки и логика сравнения

import AudioToolbox
import AVFoundation
import SpriteKit

final class Card: SKSpriteNode {
    // variables
    private var audioPlayer: AVAudioPlayer? // экземпляр класса AVAudioPlayer для воспроизведения звука
    private var isFlipped = false
    private var isOpen = false
    var isMatched = false
    // constants
    private let frontTexture: SKTexture
    private let backTexture: SKTexture
    private let imageName: String
    private let matchSoundID: SystemSoundID = 1002 // Воспроизведение звука совпадения
    private let mismatchSoundID: SystemSoundID = 1003 // Воспроизведение звука несовпадения
    
    init(frontTexture: SKTexture, backTexture: SKTexture, imageName: String) {
        self.frontTexture = frontTexture
        self.backTexture = backTexture
        self.imageName = imageName
        let texture = backTexture
        super.init(texture: texture, color: .clear, size: texture.size())
        isUserInteractionEnabled = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func flip() {
        isOpen = !isOpen
        
        let texture: SKTexture
        texture = isOpen ? frontTexture : backTexture
        
        let scaleOut = SKAction.scaleX(to: 0, duration: 0.2)
        let setTexture = SKAction.setTexture(texture)
        let scaleIn = SKAction.scaleX(to: 1, duration: 0.2)
        let flipSequence = SKAction.sequence([scaleOut, setTexture, scaleIn])
        
        run(flipSequence)
    }
    
    private func match() {
        isMatched = true
        isUserInteractionEnabled = false
    }
    
    // Вспомогательная функция для воспроизведения звука
    private func playSound(systemSoundID: SystemSoundID) { AudioServicesPlaySystemSound(systemSoundID) }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let cardScene = scene as? GameScene else { return }
        // Каждое нажатие прибавляем ход
        cardScene.movesCount += 1
        cardScene.movesTitleLabel.text = "MOVIES: \(cardScene.movesCount)"
        
        // Создаем экземпляр класса UIImpactFeedbackGenerator для воспроизведения вибрации
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        if UserDefaults.standard.bool(forKey: "isVibrationEnabled") {
            // Воспроизводим вибрацию
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Проверяем, есть ли уже открытые карты
        if cardScene.openCards.count == 1 {
            // Уже есть одна открытая карта
            let firstCard = cardScene.openCards[0]
            
            // Проверяем, является ли текущая карта уже открытой, если карта уже открыта, ничего не делаем
            if self.isFlipped || firstCard.isFlipped { return }
            
            // Сравниваем текущую карту с первой открытой картой
            if self.imageName == firstCard.imageName {
                // Карты совпали
                self.flip()
                self.match()
                firstCard.match()
                // Добавляем сопоставленные карты в массив сопоставленных карт
                cardScene.matchedCards.append(self)
                cardScene.matchedCards.append(firstCard)
                
                // Увеличиваем счетчик найденных пар
                cardScene.matchedCardsCount += 1
                            
                // Проверяем, все ли пары найдены
                if cardScene.matchedCardsCount == 8 {
                    cardScene.endGame()
                    cardScene.refreshWin.isUserInteractionEnabled = true
                }
                
                // Воспроизводим вибрацию
                if UserDefaults.standard.bool(forKey: "isVibrationEnabled") { feedbackGenerator.impactOccurred() }
                
                // Воспроизводим звук
                if UserDefaults.standard.bool(forKey: "isSoundEnabled") { playSound(systemSoundID: matchSoundID) }
                
            } else {
                // Карты не совпали, переворачиваем обратно
                self.flip()
                
                // Запускаем таймер, чтобы перевернуть текущую карту обратно через 0.5 секунды
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    self.flip()
                    firstCard.flip()
                    
                    // Включаем взаимодействие пользователя только для первой карты
                    self.isUserInteractionEnabled = true
                    firstCard.isUserInteractionEnabled = true
                }
                
                // Очищаем массив открытых карт
                cardScene.openCards.removeAll()
                
                // Воспроизводим вибрацию
                if UserDefaults.standard.bool(forKey: "isVibrationEnabled") { feedbackGenerator.impactOccurred() }
                
                // Воспроизводим звук
                if UserDefaults.standard.bool(forKey: "isSoundEnabled") { playSound(systemSoundID: mismatchSoundID) }

                // Возвращаемся из метода
                return
            }
            
            // Очищаем массив открытых карт
            cardScene.openCards.removeAll()
        } else {
            // Нет открытых карт, открываем текущую
            self.flip()
            cardScene.openCards.append(self)
        }
        // Устанавливаем isUserInteractionEnabled в false для текущей открытой карты
        self.isUserInteractionEnabled = false
    }
}
