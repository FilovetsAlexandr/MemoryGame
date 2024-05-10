//
//  MenuVC.swift
//  MemoryGame
//
//  Created by Alexandr Filovets on 30.04.24.
//
// контроллер для меню игры
import SafariServices
import UIKit

final class MenuVC: UIViewController {
    private var crownImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка фоновой картинки
        let backgroundImage = UIImageView(image: UIImage(named: "bg_menu"))
        backgroundImage.frame = view.bounds
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        // Добавление кнопки "PLAY NOW"
        let playNowButton = UIButton(type: .system)
        playNowButton.frame = CGRect(x: 50, y: view.center.y + 50, width: view.frame.width - 100, height: 50)
        playNowButton.setTitle("PLAY NOW", for: .normal)
        playNowButton.setTitleColor(.white, for: .normal)
        playNowButton.setBackgroundImage(UIImage(named: "button_bg"), for: .normal)
        playNowButton.addTarget(self, action: #selector(playNowButtonTapped), for: .touchUpInside)
        view.addSubview(playNowButton)

        // Добавление кнопки "NOTIFICATION"
        let notificationButton = UIButton(type: .system)
        notificationButton.frame = CGRect(x: 50, y: view.center.y + 110, width: view.frame.width - 100, height: 50)
        notificationButton.setTitle("NOTIFICATION", for: .normal)
        notificationButton.setTitleColor(.white, for: .normal)
        notificationButton.setBackgroundImage(UIImage(named: "button_bg"), for: .normal)
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        view.addSubview(notificationButton)

        // Добавление кнопки "PRIVACY POLICY"
        let privacyPolicyButton = UIButton(type: .system)
        privacyPolicyButton.frame = CGRect(x: 50, y: view.center.y + 170, width: view.frame.width - 100, height: 50)
        privacyPolicyButton.setTitle("PRIVACY POLICY", for: .normal)
        privacyPolicyButton.setTitleColor(.white, for: .normal)
        privacyPolicyButton.setBackgroundImage(UIImage(named: "button_bg"), for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyButtonTapped), for: .touchUpInside)
        view.addSubview(privacyPolicyButton)
    }

    // Действие при нажатии на кнопку "PLAY NOW"
    @objc private func playNowButtonTapped() {
        let gameViewController = GameViewController()
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true, completion: nil)
    }

    // Действие при нажатии на кнопку "NOTIFICATION"
    @objc private func notificationButtonTapped() {
        let notificationsVC = NotificationsVC()
        notificationsVC.modalPresentationStyle = .fullScreen
        present(notificationsVC, animated: true, completion: nil)
    }

    // Действие при нажатии на кнопку "PRIVACY POLICY"
    @objc private func privacyPolicyButtonTapped() {
        if let url = URL(string: "https://www.youtube.com/watch?v=8BctbPxfVQ8") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}
