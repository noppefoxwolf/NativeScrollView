//
//  ContentView.swift
//  Scroll
//
//  Created by Tomoya Hirano on 2019/10/09.
//  Copyright © 2019 Tomoya Hirano. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State var contentOffset: CGPoint = .zero
    var body: some View {
        VStack {
            NativeScrollView(contentOffset: $contentOffset, didScroll: { (scrollView) in
                print(scrollView.contentOffset)
            }) {
                Text("text")
                Text("text")
                Text("text")
                Text("text")
                Text("text")
                Text("text")
                Text("text")
            }.frame(width: 120, height: 120)
            Button(action: {
                self.contentOffset = .init(x: 0, y: 64)
            }) {
                Text("ok")
            }
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NativeScrollView<Content>: UIViewRepresentable where Content : View {
    typealias UIViewType = UIScrollView
    private let axes: Axis.Set
    let content: () -> Content
    @Binding var contentOffset: CGPoint
    let didScroll: (UIScrollView) -> Void
    
    init(axes: Axis.Set = .vertical,
         showsIndicators: Bool = true,
         contentOffset: Binding<CGPoint>,
         didScroll: @escaping (UIScrollView) -> Void,
         @ViewBuilder content: @escaping () -> Content) {
        self.axes = axes
        self.content = content
        self.didScroll = didScroll
        self._contentOffset = contentOffset
    }
    
    func makeUIView(context: UIViewRepresentableContext<NativeScrollView>) -> NativeScrollView.UIViewType {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        return scrollView
    }
    
    func updateUIView(_ uiView: NativeScrollView.UIViewType, context: UIViewRepresentableContext<NativeScrollView>) {
        uiView.backgroundColor = .red
        let rootView = makeRootView()
        let hostingController = UIHostingController(rootView: rootView)
        let size = hostingController.sizeThatFits(in: CGSize(width: Int.max, height: Int.max))
        hostingController.view.backgroundColor = .green
        hostingController.view.frame = .init(origin: .zero, size: size)
        uiView.addSubview(hostingController.view)
        uiView.contentSize = size
        uiView.setContentOffset(contentOffset, animated: true)
    }
    
    private func makeRootView() -> some View {
        switch self.axes {
        case .horizontal:
            return AnyView(HStack {
                self.content()
            })
        case .vertical:
            return AnyView(VStack {
                self.content()
            })
        default:
            return AnyView(EmptyView())
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension NativeScrollView {
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: NativeScrollView

        init(_ scrollView: NativeScrollView) {
            self.parent = scrollView
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.didScroll(scrollView)
        }
    }
}
