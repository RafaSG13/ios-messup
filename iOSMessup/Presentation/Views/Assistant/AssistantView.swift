//
//  AssistantView.swift
//  iOSMessup
//

import SwiftUI
import MUDesignSystem

// MARK: - ChatMessage

private struct ChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    var text: String
}

// MARK: - AssistantView

/// Chat with the on-device model about the user's own money. The model reads the data through tools and never
/// changes it.
struct AssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.intelligenceService) private var intelligenceService
    @State private var messages: [ChatMessage]
    @State private var isResponding = false
    @State private var error: (any Error)?

    init() {
        self.init(messages: [])
    }

    fileprivate init(messages: [ChatMessage]) {
        _messages = State(initialValue: messages)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: MUSpacer.size03) {
                    if messages.isEmpty {
                        AssistantEmptyState(isResponding: isResponding, onSelect: send)
                    } else {
                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                        }
                        IntelligenceDisclaimer()
                            .frame(maxWidth: .infinity)
                            .padding(.top, MUSpacer.size03)
                    }
                }
                .padding()
            }
            .defaultScrollAnchor(.bottom, for: .sizeChanges)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { AssistantInputBar(isResponding: isResponding, onSend: send) }
            .navigationTitle("Ask Messup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("New conversation", systemImage: "square.and.pencil", action: startOver)
                        .disabled(messages.isEmpty || isResponding)
                }
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension AssistantView {
    func startOver() {
        messages = []
        intelligenceService.resetConversation()
    }

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isResponding else { return }
        let reply = ChatMessage(role: .assistant, text: "")
        messages.append(ChatMessage(role: .user, text: trimmed))
        messages.append(reply)
        isResponding = true
        Task {
            do {
                for try await snapshot in intelligenceService.ask(trimmed) {
                    update(reply.id, text: snapshot)
                }
            } catch {
                messages.removeAll { $0.id == reply.id && $0.text.isEmpty }
                self.error = error
            }
            isResponding = false
        }
    }

    func update(_ id: UUID, text: String) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].text = text
        }
    }
}

// MARK: - ChatBubbleView

private struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        let isUser = message.role == .user

        Group {
            if message.text.isEmpty {
                ProgressView()
            } else {
                Text(markdown)
            }
        }
        .padding(MUSpacer.size03)
        .background(isUser ? Color.accentColor.opacity(0.18) : Color(.secondarySystemBackground),
                    in: .rect(cornerRadius: MURadius.large))
        .padding(isUser ? .leading : .trailing, MUSpacer.size09)
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isUser ? Text("You: \(message.text)") : Text("Messup: \(message.text)"))
    }

    private var markdown: AttributedString {
        (try? AttributedString(markdown: message.text,
                               options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? AttributedString(message.text)
    }
}

// MARK: - AssistantEmptyState

private struct AssistantEmptyState: View {
    let isResponding: Bool
    let onSelect: (String) -> Void

    private static var suggestions: [String] {
        [String(localized: "How much did I spend this month?"),
         String(localized: "What is my biggest category this month?"),
         String(localized: "How is my saving goal going?")]
    }

    var body: some View {
        VStack(spacing: MUSpacer.size04) {
            ContentUnavailableView("Ask about your money",
                                   systemImage: "sparkles",
                                   description: Text("Answers are generated on device with your data."))
            ForEach(Self.suggestions, id: \.self) { suggestion in
                Button { onSelect(suggestion) } label: {
                    Text(suggestion)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isResponding)
            }
        }
    }
}

// MARK: - AssistantInputBar

/// Owns the draft text, so typing does not re-evaluate the message list.
private struct AssistantInputBar: View {
    let isResponding: Bool
    let onSend: (String) -> Void
    @State private var question = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        GlassEffectContainer {
            HStack(alignment: .bottom) {
                TextField("Ask about your money", text: $question, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .onSubmit(submit)
                Button("Send", systemImage: "arrow.up", action: submit)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glassProminent)
                    .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResponding)
            }
            .padding(MUSpacer.size03)
            .glassEffect(in: .rect(cornerRadius: MURadius.large))
        }
        .padding(.horizontal)
        .padding(.bottom, MUSpacer.size03)
    }

    private func submit() {
        let text = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isResponding else { return }
        question = ""
        onSend(text)
    }
}

// MARK: - Previews

#Preview("Empty") {
    AssistantView()
}

#Preview("Conversation") {
    AssistantView(messages: [
        ChatMessage(role: .user, text: "How much did I spend this month?"),
        ChatMessage(role: .assistant, text: "You spent **1,436.02 €** this month, 36 % less than last month."),
        ChatMessage(role: .user, text: "And the biggest category?"),
        ChatMessage(role: .assistant, text: "")
    ])
}

#Preview("Failing") {
    AssistantView()
        .environment(\.intelligenceService, MockIntelligenceService(shouldFail: true))
}
