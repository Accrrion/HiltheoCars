import { useEffect, useRef, useState } from "react";
import "./FloatingAssistant.css";

const SUGGESTIONS = [
  "Help me find a car",
  "Show me SUVs in my budget",
  "How do I book a test drive?",
  "How can I contact sales?",
];

function makeId() {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function getDemoReply(message) {
  const text = message.toLowerCase();

  if (text.includes("suv") || text.includes("find") || text.includes("car") || text.includes("vehicle")) {
    return "Absolutely — I can help you find the right car. In the connected version, I’ll search the dealership’s live inventory. What make, budget, or body type do you have in mind?";
  }
  if (text.includes("test drive") || text.includes("test-drive")) {
    return "I can help you arrange a test drive. Once connected, I’ll guide you through the dealership’s booking process or help you contact the sales team.";
  }
  if (text.includes("contact") || text.includes("sales") || text.includes("whatsapp")) {
    return "I can help you reach the sales team. The live version will use the dealership’s configured contact details, so no contact information is guessed.";
  }
  if (text.includes("price") || text.includes("budget") || text.includes("₦") || text.includes("naira")) {
    return "I can help narrow down vehicles by budget. In the connected version, I’ll check actual listing prices before showing you matching cars. What’s your maximum budget?";
  }

  return "I’m your dealership assistant demo. I’ll be able to guide you around the website, search real vehicle listings, compare cars, and help with enquiries once the backend is connected.";
}

export default function FloatingAssistant() {
  const [isOpen, setIsOpen] = useState(false);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const [messages, setMessages] = useState([
    {
      id: "welcome",
      role: "assistant",
      text: "Hi there! 👋 I’m your dealership assistant. I can help you explore the website and find the right car. What can I help you with?",
    },
  ]);
  const listRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      listRef.current?.scrollTo({
        top: listRef.current.scrollHeight,
        behavior: "smooth",
      });
      inputRef.current?.focus();
    }
  }, [isOpen, messages, isTyping]);

  function sendMessage(rawText = input) {
    const text = rawText.trim();
    if (!text || isTyping) return;

    setMessages((current) => [
      ...current,
      { id: makeId(), role: "user", text },
    ]);
    setInput("");
    setIsTyping(true);

    // Demo only: replace this timeout and getDemoReply() with a POST to /api/agent.
    window.setTimeout(() => {
      setMessages((current) => [
        ...current,
        { id: makeId(), role: "assistant", text: getDemoReply(text) },
      ]);
      setIsTyping(false);
    }, 650);
  }

  return (
    <div className="dealership-ai">
      {isOpen && (
        <section
          className="dealership-ai__panel"
          role="dialog"
          aria-modal="false"
          aria-labelledby="dealership-ai-title"
        >
          <header className="dealership-ai__header">
            <div className="dealership-ai__identity">
              <div className="dealership-ai__avatar" aria-hidden="true">
                <AssistantIcon />
              </div>
              <div>
                <h2 id="dealership-ai-title">Dealership Assistant</h2>
                <p><span className="dealership-ai__status-dot" /> Here to help</p>
              </div>
            </div>
            <button
              className="dealership-ai__icon-button"
              type="button"
              onClick={() => setIsOpen(false)}
              aria-label="Close assistant"
              title="Close"
            >
              <CloseIcon />
            </button>
          </header>

          <div className="dealership-ai__messages" ref={listRef} aria-live="polite">
            <div className="dealership-ai__demo-note">
              Preview mode · AI backend not connected
            </div>
            {messages.map((message) => (
              <div
                className={`dealership-ai__message dealership-ai__message--${message.role}`}
                key={message.id}
              >
                {message.role === "assistant" && (
                  <span className="dealership-ai__message-avatar" aria-hidden="true">
                    <AssistantIcon />
                  </span>
                )}
                <p>{message.text}</p>
              </div>
            ))}

            {isTyping && (
              <div className="dealership-ai__message dealership-ai__message--assistant">
                <span className="dealership-ai__message-avatar" aria-hidden="true">
                  <AssistantIcon />
                </span>
                <div className="dealership-ai__typing" aria-label="Assistant is typing">
                  <span /><span /><span />
                </div>
              </div>
            )}

            {messages.length === 1 && !isTyping && (
              <div className="dealership-ai__suggestions">
                <span className="dealership-ai__suggestions-label">TRY ASKING</span>
                {SUGGESTIONS.map((suggestion) => (
                  <button
                    type="button"
                    className="dealership-ai__suggestion"
                    key={suggestion}
                    onClick={() => sendMessage(suggestion)}
                  >
                    {suggestion}
                    <span aria-hidden="true">↗</span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <form
            className="dealership-ai__composer"
            onSubmit={(event) => {
              event.preventDefault();
              sendMessage();
            }}
          >
            <label className="dealership-ai__sr-only" htmlFor="dealership-ai-input">
              Message the dealership assistant
            </label>
            <input
              ref={inputRef}
              id="dealership-ai-input"
              value={input}
              onChange={(event) => setInput(event.target.value)}
              placeholder="Ask me anything..."
              maxLength={1200}
              autoComplete="off"
            />
            <button
              className="dealership-ai__send"
              type="submit"
              disabled={!input.trim() || isTyping}
              aria-label="Send message"
            >
              <SendIcon />
            </button>
          </form>
          <footer className="dealership-ai__footer">
            AI can make mistakes. Confirm vehicle details with the dealership.
          </footer>
        </section>
      )}

      <button
        type="button"
        className={`dealership-ai__launcher ${isOpen ? "dealership-ai__launcher--open" : ""}`}
        onClick={() => setIsOpen((open) => !open)}
        aria-label={isOpen ? "Close dealership assistant" : "Open dealership assistant"}
        aria-expanded={isOpen}
      >
        {isOpen ? <CloseIcon /> : <><AssistantIcon /><span className="dealership-ai__launcher-label">Ask AI</span></>}
        {!isOpen && <span className="dealership-ai__launcher-pulse" aria-hidden="true" />}
      </button>
    </div>
  );
}

function AssistantIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path d="M12 3.2 13.9 9l5.8 2-5.8 1.9-1.9 5.8-1.9-5.8-5.8-1.9 5.8-2L12 3.2Z" />
      <path d="m19 15 .9 2.1L22 18l-2.1.9L19 21l-.9-2.1L16 18l2.1-.9L19 15Z" />
    </svg>
  );
}

function CloseIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path d="m6 6 12 12M18 6 6 18" />
    </svg>
  );
}

function SendIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path d="m21 3-7.1 18-3.8-7.1L3 10.1 21 3Z" />
      <path d="M10.1 13.9 15 9" />
    </svg>
  );
}
