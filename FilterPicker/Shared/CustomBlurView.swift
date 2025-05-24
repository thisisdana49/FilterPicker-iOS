//
//  CustomBlurView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct CustomBlurView: UIViewRepresentable {
  var style: UIBlurEffect.Style

  func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: style))
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
} 
