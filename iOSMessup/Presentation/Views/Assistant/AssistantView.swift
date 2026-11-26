//
//  AssistantView.swift
//  iOSMessup
//

import SwiftUI
import MUDesignSystem

// MARK: - ChatMessage

private struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user
        case assistant
        /// Something the assistant changed (created, updated or deleted), shown as a card instead of a bubble.
        case action(AssistantActionCenter.ActionEvent)
    }

    let id = UUID()
    let role: Role
    var text: String
}

// MARK: - AssistantView

/// Chat with the on-device model about the user's own money. The model reads the data through tools and can create,
/// edit and delete it; every change shows up as a card and every deletion waits for the user's confirmation.
struct AssistantView: View {
    @Environment(\.intelligenceService) private var intelligenceService
    @State private var messages: [ChatMessage]
    @State private var replyID: UUID?
    @State private var isResponding = false
    @State private var error: (any Error)?

    init() {
        self.init(messages: [])
    }

    fileprivate init(messages: [ChatMessage]) {
        _messages = State(initialValue: messages)
    }

    var body: some View {
        let availability = intelligenceService.availability

        NavigationStack {
            Group {
                if availability == .available {
                    AssistantChat(messages: messages,
                                  isResponding: isResponding,
                                  onSend: send,
                                  onError: { error = $0 })
                } else {
                    ContentUnavailableView("Assistant unavailable",
                                           systemImage: "sparkles",
                                           description: Text(availability.statusText))
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if availability == .available {
                    ToolbarItem(placement: .primaryAction) {
                        Button("New conversation", systemImage: "square.and.pencil", action: startOver)
                            .disabled(messages.isEmpty || isResponding)
                    }
                }
            }
            .errorAlert($error)
            .onChange(of: intelligenceService.actionCenter.lastEvent) { _, event in
                if let event { show(event) }
            }
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
        replyID = reply.id
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
            replyID = nil
            isResponding = false
        }
    }

    func update(_ id: UUID, text: String) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].text = text
        }
    }

    /// The card goes before the reply that is being written, so it reads as "did this, then said that".
    func show(_ event: AssistantActionCenter.ActionEvent) {
        let card = ChatMessage(role: .action(event), text: "")
        if let replyID, let index = messages.firstIndex(where: { $0.id == replyID }) {
            messages.insert(card, at: index)
        } else {
            messages.append(card)
        }
    }
}

// MARK: - AssistantChat

private struct AssistantChat: View {
    let messages: [ChatMessage]
    let isResponding: Bool
    let onSend: (String) -> Void
    let onError: (any Error) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MUSpacer.size04) {
                if messages.isEmpty {
                    AssistantEmptyState(isResponding: isResponding, onSelect: onSend)
                } else {
                    ForEach(messages) { message in
                        ChatRow(message: message)
                    }
                    IntelligenceDisclaimer()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(MUSpacer.size04)
        }
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .defaultScrollAnchor(messages.isEmpty ? .center : .bottom, for: .alignment)
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            GlassEffectContainer(spacing: MUSpacer.size03) {
                VStack(spacing: MUSpacer.size03) {
                    ConfirmationBar()
                    AssistantInputBar(isResponding: isResponding, onSend: onSend, onError: onError)
                }
            }
            .padding(.horizontal, MUSpacer.size04)
            .padding(.bottom, MUSpacer.size03)
        }
    }
}

// MARK: - ChatRow

private struct ChatRow: View {
    let message: ChatMessage

    var body: some View {
        switch message.role {
        case .action(let event):
            ActionCardView(event: event)
        case .user, .assistant:
            ChatBubbleView(message: message)
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
        .padding(.vertical, MUSpacer.size03)
        .padding(.horizontal, MUSpacer.size04)
        .background(isUser ? Color.accentColor.opacity(0.18) : Color(.secondarySystemGroupedBackground),
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

// MARK: - ActionCardView

/// What the assistant just did to the user's data.
private struct ActionCardView: View {
    @ScaledMetric private var iconSize: CGFloat = 32
    let event: AssistantActionCenter.ActionEvent

    var body: some View {
        MUAdaptiveStack(spacing: MUSpacer.size03) {
            MUIconTile(systemImage: event.systemImage, tint: .accentColor, size: iconSize)
            VStack(alignment: .leading, spacing: MUSpacer.size01) {
                Text(event.title)
                    .font(.subheadline.bold())
                Text(event.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, MUSpacer.size03)
        .padding(.horizontal, MUSpacer.size04)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: MURadius.large))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - AssistantEmptyState

private struct AssistantSuggestion: Identifiable {
    let text: String
    let systemImage: String
    var id: String { text }
}

private struct AssistantEmptyState: View {
    @ScaledMetric private var heroIconSize: CGFloat = 56
    let isResponding: Bool
    let onSelect: (String) -> Void

    private static var suggestions: [AssistantSuggestion] {
        [AssistantSuggestion(text: String(localized: "How much did I spend this month?"), systemImage: "chart.bar"),
         AssistantSuggestion(text: String(localized: "Add a coffee for 3.50 yesterday"), systemImage: "plus.circle"),
         AssistantSuggestion(text: String(localized: "Who owes me money?"), systemImage: "person.2"),
         AssistantSuggestion(text: String(localized: "Delete my last expense"), systemImage: "trash")]
    }

    var body: some View {
        VStack(spacing: MUSpacer.size06) {
            VStack(spacing: MUSpacer.size03) {
                MUIconTile(systemImage: "sparkles", tint: .accentColor, size: heroIconSize)
                Text("Ask about your money or tell me what to do")
                    .font(.title3.bold())
                Text("Answers are generated on device with your data.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
            VStack(spacing: MUSpacer.size03) {
                ForEach(Self.suggestions) { suggestion in
                    SuggestionButton(suggestion: suggestion, isDisabled: isResponding, onSelect: onSelect)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SuggestionButton

private struct SuggestionButton: View {
    @ScaledMetric(relativeTo: .subheadline) private var iconWidth: CGFloat = 24
    let suggestion: AssistantSuggestion
    let isDisabled: Bool
    let onSelect: (String) -> Void

    var body: some View {
        Button { onSelect(suggestion.text) } label: {
            HStack(spacing: MUSpacer.size03) {
                Image(systemName: suggestion.systemImage)
                    .foregroundStyle(.tint)
                    .frame(width: iconWidth)
                    .accessibilityHidden(true)
                Text(suggestion.text)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.subheadline.weight(.medium))
            .padding(MUSpacer.size04)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: MURadius.medium))
            .contentShape(.rect(cornerRadius: MURadius.medium))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - ConfirmationBar

/// Reads the pending deletion request; shown above the input bar until the user answers.
private struct ConfirmationBar: View {
    @Environment(\.intelligenceService) private var intelligenceService

    var body: some View {
        let center = intelligenceService.actionCenter
        if let request = center.pending {
            ConfirmationCard(request: request, onResolve: center.resolve)
        }
    }
}

// MARK: - ConfirmationCard

private struct ConfirmationCard: View {
    let request: AssistantActionCenter.ConfirmationRequest
    let onResolve: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size04) {
            VStack(alignment: .leading, spacing: MUSpacer.size01) {
                Text(request.title)
                    .font(.headline)
                ForEach(request.details, id: \.self) { detail in
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            MUAdaptiveStack(spacing: MUSpacer.size03) {
                Button(role: .cancel) { onResolve(false) } label: {
                    Text("Cancel").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                Button(role: .destructive) { onResolve(true) } label: {
                    Text(request.confirmLabel).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
        }
        .padding(MUSpacer.size04)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(in: .rect(cornerRadius: MURadius.large))
        .accessibilityElement(children: .contain)
    }
}

// MARK: - AssistantInputBar

/// Owns the draft text, so typing does not re-evaluate the message list. Dictation only fills the field: the user
/// reviews the text and presses Send.
private struct AssistantInputBar: View {
    @Environment(\.dictationService) private var dictationService
    let isResponding: Bool
    let onSend: (String) -> Void
    let onError: (any Error) -> Void
    @State private var question = ""
    @State private var baseText = ""
    @State private var isDictationAvailable = false
    @State private var isRecording = false
    @FocusState private var isInputFocused: Bool
    @State private var controlHeight: CGFloat = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: MUSpacer.size03) {
            TextField("Ask or tell Messup…", text: $question, axis: .vertical)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .onSubmit(submit)
                .padding(.vertical, MUSpacer.size02)
                .padding(.leading, MUSpacer.size03)
                .frame(minHeight: controlHeight)
            if isDictationAvailable {
                Button(isRecording ? "Stop dictation" : "Dictate",
                       systemImage: isRecording ? "stop.circle.fill" : "mic",
                       action: toggleDictation)
                    .labelStyle(.iconOnly)
                    .symbolEffect(.pulse, isActive: isRecording)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .disabled(isResponding)
            }
            Button("Send", systemImage: "arrow.up", action: submit)
                .labelStyle(.iconOnly)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResponding)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { controlHeight = $0 }
        }
        .padding(MUSpacer.size03)
        .glassEffect(in: .rect(cornerRadius: controlHeight / 2 + MUSpacer.size03))
        .task { isDictationAvailable = await dictationService.isAvailable() }
        .onDisappear(perform: stopDictation)
    }

    private func submit() {
        let text = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isResponding else { return }
        stopDictation()
        question = ""
        onSend(text)
    }

    private func toggleDictation() {
        guard !isRecording else {
            stopDictation()
            return
        }
        baseText = question
        isRecording = true
        Task {
            do {
                for try await text in try await dictationService.start() {
                    question = baseText.isEmpty ? text : baseText + " " + text
                }
            } catch {
                onError(error)
            }
            isRecording = false
        }
    }

    private func stopDictation() {
        guard isRecording else { return }
        Task { await dictationService.stop() }
    }
}

// MARK: - Previews

#Preview("Empty") {
    AssistantView()
}

#Preview("Conversation") {
    AssistantView(messages: [
        ChatMessage(role: .user, text: "Add a coffee for 3.50 yesterday"),
        ChatMessage(role: .action(.init(systemImage: "plus.circle",
                                        title: "Created expense",
                                        detail: "Coffee · 3.50 € · 2026-11-24")),
                    text: ""),
        ChatMessage(role: .assistant, text: "Done, I added **Coffee** for 3.50 €."),
        ChatMessage(role: .user, text: "How much did I spend this month?"),
        ChatMessage(role: .assistant, text: "")
    ])
}

#if DEBUG
#Preview("Confirming deletion") {
    let service = MockIntelligenceService()
    service.actionCenter.preview(pending: .init(title: "Delete expense?",
                                                details: ["Coffee · 3.50 € · 2026-11-24"],
                                                confirmLabel: "Delete"))
    return AssistantView(messages: [
        ChatMessage(role: .user, text: "Delete the coffee"),
        ChatMessage(role: .assistant, text: "")
    ])
    .environment(\.intelligenceService, service)
}
#endif

#Preview("Unavailable") {
    AssistantView()
        .environment(\.intelligenceService, MockIntelligenceService(availability: .appleIntelligenceNotEnabled))
}

#Preview("Failing") {
    AssistantView()
        .environment(\.intelligenceService, MockIntelligenceService(shouldFail: true))
}
