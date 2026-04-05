# Sara AI-voice_assistant_app

## overview

Sara AI is a prototype voice assistant application inspired by modern conversational AI platforms like chat Gpt, Gemini and Siri. The app allows users to interact using both voice and text input. It focuses on delivering a smooth chat-based experience with clear interaction states such as listening, processing, and responding.
This project is built using Flutter and demonstrates how a voice-enabled interface can be designed without relying on a full backend AI system.

## features

- Speech-to-text (voice input)
- Text-based input
- Text-to-speech (manual playback using speaker button)
- Chat-based UI interface
- Typing/processing indicator
- Chat history
- Clean dark UI with gradient and glow effects
- Voice listening waveform animation

## Tech stack

- Flutter (UI framework)
- Dart (programming language)
- speech_to_text (voice recognition)
- flutter_tts (text-to-speech)
- shared_preferences (local storage)

## Approach

The application captures user input either through voice or text. Voice input is converted into text using speech-to-text functionality. The system then processes the input and generates a response using simulated AI logic.

The UI dynamically updates to reflect different states such as listening, typing, and responding. Text-to-speech is implemented with manual control, allowing users to play responses when needed.

## Future Scope

- Integration with real AI APIs for dynamic responses
- More advanced natural language processing
- Improved animations and voice visualization
- Multi-language support

## Screenshots

### 🏠 Home Screen

![Home](image/homepage.png)

### 💬 Chat Screen

![Chat](image/chat.png)

### 🎤 Voice Listening State

![Voice](image/listening_state.png)
