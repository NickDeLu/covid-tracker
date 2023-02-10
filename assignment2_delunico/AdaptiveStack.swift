//
//  AdaptiveStack.swift
//  lab11_adaptive_delunico
//
//  Created by Nick De Luca on 2022-12-07.
//

import Foundation
import SwiftUI

struct AdaptiveStack<Content:View>: View {
    @Environment(\.verticalSizeClass) var vSizeClass
    var hAlignment: HorizontalAlignment
    var vAlignment: VerticalAlignment
    var spacing: CGFloat
    var content: () -> Content
    
    init(hAlignment: HorizontalAlignment = .center,
         vAlignment: VerticalAlignment = .center,
         spacing: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content){
        self.vAlignment = vAlignment
        self.hAlignment = hAlignment
        self.spacing  = spacing
        self.content = content
    }
    
    var body: some View {
        if(vSizeClass == .regular){
            VStack(alignment: hAlignment, spacing: spacing, content: content)
        }else{
            HStack(alignment: vAlignment, spacing: spacing, content: content)
        }
    }
    
}
