//
//  SplashViewController.swift
//  MemoryGame
//
//  Created by Alexandr Filovets on 30.04.24.
//
// контроллер для загрузочного экрана
import UIKit

final class SplashVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка фоновой картинки
        let backgroundImage = UIImageView(image: UIImage(named: "bg1"))
        backgroundImage.frame = view.bounds
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        // Добавление элементов bg2
        let bg2ImageView = UIImageView(image: UIImage(named: "bg2"))
        bg2ImageView.frame = view.bounds
        bg2ImageView.contentMode = .scaleAspectFill
        view.addSubview(bg2ImageView)
        
        // Создайте анимацию загрузки
        let loadingImageView = UIImageView(image: UIImage(named: "fire"))
        loadingImageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        loadingImageView.center = self.view.center
        self.view.addSubview(loadingImageView)
        
        // Анимация перемещения вверх и вниз
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: { loadingImageView.frame.origin.y -= 200 }, completion: nil)
        
        // Загрузка завершена через некоторое время
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { self.showMainVC() }
    }
    
    private func showMainVC() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = mainStoryboard.instantiateInitialViewController()
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainViewController
        }
    }
}
