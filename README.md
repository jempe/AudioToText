# AudioToText

A macOS application that transcribes audio files to text using Apple's Speech Recognition framework.

## Features

- Transcribe audio files to text
- Support for multiple audio formats (m4a, mp3, wav, aiff, aifc, caf)
- Real-time transcription progress updates
- Save transcriptions as text files
- Clean and intuitive user interface

## Requirements

- macOS 11.0 or later
- Xcode 13.0 or later (for development)
- Microphone access permission (for Speech Recognition)

## Installation

### For Developers

1. Clone the repository:
   ```bash
   git clone https://github.com/jempe/AudioToText.git
   cd AudioToText
   ```

2. Open the project in Xcode:
   ```bash
   open AudioToText.xcodeproj
   ```

3. Build and run the application (⌘+R)

## Usage

1. Launch the AudioToText application
2. Click on "Select Audio File and Transcribe" button
3. Choose an audio file from your computer
4. Wait for the transcription process to complete
5. Once finished, the transcribed text will appear in the text area
6. Click "Download Transcription" to save the text to a file

## Privacy

AudioToText uses Apple's Speech Recognition framework which processes audio locally on your device. No audio data is sent to external servers. The app requires permission to access Speech Recognition, which you'll be prompted for on first use.

## Troubleshooting

- **Speech Recognition Authorization Denied**: Go to System Settings > Privacy & Security > Speech Recognition and enable it for AudioToText
- **Unsupported Audio Format**: Convert your audio to one of the supported formats (m4a, mp3, wav, aiff, aifc, caf)
- **Poor Transcription Quality**: Ensure the audio is clear with minimal background noise

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Acknowledgments

- [Apple Speech Framework](https://developer.apple.com/documentation/speech)
- SwiftUI for the user interface

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
