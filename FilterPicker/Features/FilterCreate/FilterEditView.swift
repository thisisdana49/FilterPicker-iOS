//
//  FilterEditView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct FilterEditView: View {
    @StateObject private var store: FilterEditStore
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarVisibility: TabBarVisibilityManager
    
    init(image: UIImage) {
        self._store = StateObject(wrappedValue: FilterEditStore(image: image))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            CustomNavigationBar(
                title: "EDIT",
                showBackButton: true,
                onBackTapped: {
                    // 뒤로가기 시 탭바 제어는 onDisappear에서 처리
                    presentationMode.wrappedValue.dismiss()
                },
                rightButton: AnyView(
                    Button(action: {
                        store.send(.saveChanges)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                )
            )
            
            // 메인 이미지 영역
            imageSection
            
            // 하단 컨트롤 영역
            controlSection
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onAppear {
            // 탭바 숨김 확인
            withAnimation(.easeInOut(duration: 0.3)) {
                tabBarVisibility.hideTabBar()
            }
        }
    }
}

// MARK: - View Components
extension FilterEditView {
    
    private var imageSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = store.state.editedImage ?? store.state.originalImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.gray.opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Undo/Redo 버튼들
            undoRedoButtons
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
    }
    
    private var undoRedoButtons: some View {
        HStack(spacing: 12) {
            // Undo 버튼
            Button(action: {
                store.send(.undo)
            }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title2)
                    .foregroundColor(store.state.canUndo ? .white : .gray)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .disabled(!store.state.canUndo)
            
            // Redo 버튼
            Button(action: {
                store.send(.redo)
            }) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.title2)
                    .foregroundColor(store.state.canRedo ? .white : .gray)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .disabled(!store.state.canRedo)
        }
        .padding(.leading, 16)
        .padding(.bottom, 16)
    }
    
    private var controlSection: some View {
        VStack(spacing: 20) {
            // 파라미터 선택 버튼들
            parameterButtons
            
            // 슬라이더와 값 표시
            sliderSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.black)
    }
    
    private var parameterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(FilterParameter.allCases, id: \.self) { parameter in
                    Button(action: {
                        store.send(.selectParameter(parameter))
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: parameter.icon)
                                .font(.title3)
                            
                            Text(parameter.displayName)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .foregroundColor(store.state.selectedParameter == parameter ? .white : .gray)
                        .frame(width: 80)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var sliderSection: some View {
        VStack(spacing: 12) {
            // 현재 값 표시 (사용자 친화적인 값)
            Text(String(format: "%.0f", store.state.currentParameterDisplayValue))
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // 슬라이더
            HStack {
                Text(String(format: "%.0f", displayRange.lowerBound))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Slider(
                    value: Binding(
                        get: { store.state.currentParameterDisplayValue },
                        set: { store.send(.updateParameterValue($0)) }
                    ),
                    in: displayRange,
                    step: 1.0,
                    onEditingChanged: { isEditing in
                        if isEditing {
                            // 슬라이더 편집 시작 시 스냅샷 저장
                            store.send(.startEditingParameter)
                        }
                    }
                )
                .accentColor(.blue)
                
                Text(String(format: "%.0f", displayRange.upperBound))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 색상 그라데이션 바 (시안에서 보이는 효과)
            // Rectangle()
            //     .fill(
            //         LinearGradient(
            //             gradient: Gradient(colors: [
            //                 .purple, .blue, .pink, .green, .yellow, .orange, .red
            //             ]),
            //             startPoint: .leading,
            //             endPoint: .trailing
            //         )
            //     )
            //     .frame(height: 4)
            //     .cornerRadius(2)
        }
    }
    
    // 사용자에게 보이는 슬라이더 범위
    private var displayRange: ClosedRange<Float> {
        switch store.state.selectedParameter {
        case .brightness, .exposure, .sharpness, .blur, .vignette, .noiseReduction, .highlights, .shadows, .blackPoint:
            return -100.0...100.0
        case .contrast, .saturation, .temperature:
            return 0.0...100.0
        }
    }
} 
