//
//  NotificationsVC.swift
//  MemoryGame
//
//  Created by Alexandr Filovets on 30.04.24.
//
// контроллер для экрана нотификашек
import UIKit

final class NotificationsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка фоновой картинки
        let backgroundImage = UIImageView(image: UIImage(named: "notification_bg"))
        backgroundImage.frame = view.bounds
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        // Добавление кнопки "bonuses"
        let bonusesButton = UIButton(type: .system)
        bonusesButton.frame = CGRect(x: 50, y: view.frame.height - 160, width: view.frame.width - 100, height: 50)
        bonusesButton.setTitle("Yes, I Want Bonuses!", for: .normal)
        bonusesButton.setTitleColor(.black, for: .normal)
        bonusesButton.setBackgroundImage(UIImage(named: "button_bg1"), for: .normal)
        bonusesButton.addTarget(self, action: #selector(bonusesButtonTapped), for: .touchUpInside)
        view.addSubview(bonusesButton)

        // Добавление кнопки "Skip"
        let skipButton = UIButton(type: .system)
        skipButton.frame = CGRect(x: 50, y: view.frame.height - 100, width: view.frame.width - 100, height: 50)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.backgroundColor = .clear
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        view.addSubview(skipButton)
    }

    // Действие при нажатии на кнопку "bonuses"
    @objc private func bonusesButtonTapped() { print("button bonuses tapped") }

    // Действие при нажатии на кнопку "Skip"
    @objc private func skipButtonTapped() { dismiss(animated: true, completion: nil) }
}
