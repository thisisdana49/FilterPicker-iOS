//
//  Icon.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct Icon: View {
    let name: String
    var size: CGFloat = 24
    var color: Color = .fpGray90

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}
