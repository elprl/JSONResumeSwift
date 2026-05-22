//
//  MessageScrollView18.swift
//  OpenCV
//
//  Created by Paul Leo on 20/07/2024.
//
import SwiftUI
import Combine

@available(iOS 18.0, *)
struct MessageScrollView18: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var scrollPosition = ScrollPosition(idType: ChatMessage.ID.self)
    var viewModel: AIChatMessagesViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                topPadding
                ForEach(viewModel.messages) { message in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.viewModel.selectedMessageId = message.messageId
                        }
                    }, label: {
                        AIChatMessageRowView(viewModel: viewModel, message: message)
                            .padding(.horizontal, horizonPadding)
                            .padding(.bottom, 8)
                            .id(message.id)
                    })
                    .transition(.slide)
                }
                bottomPadding
                    .onScrollVisibilityChange(threshold: 0.5) { isLast in
                        self.viewModel.scrollLockPublisher.send(isLast)
                    }
            }
            .scrollTargetLayout()
        }
        .task {
            withAnimation {
                self.scrollPosition.scrollTo(edge: .bottom)
            }
        }
        .onChange(of: viewModel.agiContentCount) {
            withAnimation {
                self.scrollPosition.scrollTo(edge: .bottom)
            }
        }
        .contentMargins(.top, 100.0, for: .scrollIndicators)
        .contentMargins(.bottom, 120.0, for: .scrollIndicators)
        .scrollPosition($scrollPosition)
        .overlay(scrollToBottom)
    }
    
    @ViewBuilder
    var scrollToBottom: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                RoundButton(action: {
                    withAnimation {
                        self.scrollPosition.scrollTo(edge: .bottom)
                    }
                }, imageSize: 44, icon: "chevron.down", bgColor: .blue, isLoading: .constant(false))
                .shadow(radius: 3)
                .padding(.bottom, 130)
                .padding(.trailing)
                .disabled(viewModel.isScrollLockActive)
                .opacity(viewModel.isScrollLockActive ? 0 : 1)
            }
        }
    }
    
    @ViewBuilder
    var topPadding: some View {
        Color.clear
            .frame(width: 0, height: 120, alignment: .bottom)
            .id(0)
    }
    
    @ViewBuilder
    var bottomPadding: some View {
        Color.clear
            .frame(width: 0, height: 380, alignment: .bottom)
    }
    
    private var horizonPadding: CGFloat {
        if horizontalSizeClass == .regular {
            return 48
        } else {
            return 16
        }
    }
}

struct MessageScrollView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var viewModel: AIChatMessagesViewModel
    @State private var didPressScrollToBottom: Bool = false

    var body: some View {
        ScrollViewReader { outerProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    topPadding
                    ForEach(viewModel.messages) { message in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.viewModel.selectedMessageId = message.messageId
                            }
                        }, label: {
                            AIChatMessageRowView(viewModel: viewModel, message: message)
                                .padding(.horizontal, horizonPadding)
                                .padding(.bottom, 8)
                        })
                        .transition(.slide)
                        .id(message.id)
                    }
                    bottomPadding
                }
                .animation(.default, value: viewModel.messages)
            }
            .contentMargins(.top, 100.0, for: .scrollIndicators)
            .contentMargins(.bottom, 120.0, for: .scrollIndicators)
            .overlay(scrollToBottom)
            .task {
                withAnimation {
                    outerProxy.scrollTo(Int.max, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.agiContentCount) {
                withAnimation {
                    outerProxy.scrollTo(Int.max, anchor: .bottom)
                }
            }
            .onChange(of: self.didPressScrollToBottom) {
                withAnimation {
                    if self.didPressScrollToBottom {
                        outerProxy.scrollTo(Int.max, anchor: .bottom)
                        self.didPressScrollToBottom = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var scrollToBottom: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                RoundButton(action: {
                    withAnimation {
                        self.didPressScrollToBottom = true
                    }
                }, imageSize: 44, icon: "chevron.down", bgColor: .blue, isLoading: .constant(false))
                .shadow(radius: 3)
                .padding(.bottom, 130)
                .padding(.trailing)
//                .disabled(viewModel.isScrollLockActive)
//                .opacity(viewModel.isScrollLockActive ? 0 : 1)
            }
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    var topPadding: some View {
        Color.clear
            .frame(width: 0, height: 120, alignment: .bottom)
            .id(0)
    }
    
    @ViewBuilder
    var bottomPadding: some View {
        Color.clear
            .frame(width: 0, height: 380, alignment: .bottom)
            .id(Int.max)
    }
    
    private var horizonPadding: CGFloat {
        if horizontalSizeClass == .regular {
            return 48
        } else {
            return 16
        }
    }
}
