//
//  DraggableBottomSheet.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 09/03/25.
//

import SwiftUI


struct DraggableBottomSheet<Content: View>: View {
    // offset: 0 = fully expanded; offset = (maxHeight - minHeight) = collapsed
    @Binding var offset: CGFloat
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let bottomMargin: CGFloat
    let content: Content
    
    @GestureState private var dragOffset: CGFloat = 0
    
    // Total drag distance.
    private var dragRange: CGFloat { maxHeight - minHeight }
    // Current effective offset.
    private var currentOffset: CGFloat { offset + dragOffset }
    
    init(
        offset: Binding<CGFloat>,
        maxHeight: CGFloat,
        minHeight: CGFloat,
        bottomMargin: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self._offset = offset
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self.bottomMargin = bottomMargin
        self.content = content()
    }
    
    var body: some View {
        let dragGesture = DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                // Use a small threshold to decide snapping.
                let threshold: CGFloat = 10
                // Determine direction.
                if value.translation.height < -threshold {
                    // Swiped upward: snap open using a fast spring.
                    withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.8, blendDuration: 0.1)) {
                        offset = 0
                    }
                } else if value.translation.height > threshold {
                    // Swiped downward: snap closed using a slightly slower spring.
                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.2)) {
                        offset = dragRange
                    }
                }
            }
        
        return VStack(spacing: 0) {
            // Drag handle.
            Capsule()
                .fill(Color.gray)
                .frame(width: 40, height: 6)
                .padding(8)
            
            // Sheet content.
            content
                .padding(.bottom, 16)
        }
        .frame(width: UIScreen.main.bounds.width, height: maxHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        //.shadow(radius: 5)
        // The sheet's vertical offset: currentOffset plus a bottom margin.
        .offset(y: currentOffset + bottomMargin)
        .gesture(dragGesture)
    }
}


