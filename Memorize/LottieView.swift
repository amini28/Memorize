//
//  LottieView.swift
//  Memorize
//
//  Created by Amini on 01/06/22.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    typealias UIViewType = UIView
    var filename: String
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = AnimationView()
        let animation = Animation.named(filename)
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play(completion: {(finished) in
            if finished {
                print("animation finished")
            } else {
                print("animation canceled")
            }
        })
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                     animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
                                    ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}
