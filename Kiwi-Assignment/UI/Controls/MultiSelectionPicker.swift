import SwiftUI

struct MultiSelectionPicker<Label: View, SelectionValue: Hashable, Content: View, CollapsedContent: View>: View {
    private var sources: [SelectionValue]
    @Binding private var selection: Set<SelectionValue>
    private var content: (SelectionValue) -> Content
    private var collapsedContent: CollapsedContent
    private var label: Label
    
    @State private var isExpanded = false
    
    private var selectAllDisabled: Bool {
        sources.count == selection.count
    }
    
    var body: some View {
        VStack {
            HStack {
                if !isExpanded {
                    label
                        .transition(
                            .move(edge: .leading)
                            .combined(with: .offset(CGSize(width: -64, height: 0)))
                            .combined(with: .opacity.animation(.default.speed(2)))
                        )
                    
                    Spacer()
                    
                    collapsedContent
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .transition(
                            .move(edge: .trailing)
                            .combined(with: .offset(CGSize(width: 64, height: 0)))
                            .combined(with: .opacity.animation(.default.speed(2)))
                        )
                } else {
                    Button("Select all") {
                        sources.forEach { selection.insert($0) }
                    }
                    .disabled(selectAllDisabled || !isExpanded)
                    .transition(
                        .move(edge: .leading)
                        .combined(with: .opacity.animation(.default.speed(2)))
                    )
                    
                    Spacer()
                }
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            
            if isExpanded {
                VStack {
                    Divider()
                    
                    ForEach(sources.indices, id: \.self) { index in
                        let currentValue = sources[index]
                        let isLastIndex = index == sources.indices.last
                        
                        Button {
                            if selection.contains(currentValue) {
                                selection.remove(currentValue)
                            } else {
                                selection.insert(currentValue)
                            }
                        } label: {
                            content(currentValue)
                        }
                        .buttonStyle(.checkmark(selected: selection.contains(currentValue)))
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                        .padding(.bottom, isLastIndex ? 0 : 8)
                        
                        if !isLastIndex {
                            Divider()
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .background(
            .background.shadow(.drop(radius: 5, y: 2)),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .onTapGesture {
            isExpanded.toggle()
        }
        .animation(.default, value: isExpanded)
    }
    
    init(
        sources: [SelectionValue],
        selection: Binding<Set<SelectionValue>>,
        @ViewBuilder content: @escaping (SelectionValue) -> Content,
        @ViewBuilder collapsedContent: () -> CollapsedContent,
        @ViewBuilder label: () -> Label
    ) {
        self.sources = sources
        self._selection = selection
        self.content = content
        self.collapsedContent = collapsedContent()
        self.label = label()
    }
}

#Preview {
    MultiSelectionPicker(sources: [1, 2, 3], selection: .constant([2])) { index in
        Text(index, format: .number)
    } collapsedContent: {
        HStack {
            Text("1")
            Text("2")
            Text("3")
        }
    } label: {
        Text("Picker")
    }
    .padding()
}
