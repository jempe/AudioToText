import SwiftUI
import Speech
import UniformTypeIdentifiers

// Main view of the application
struct ContentView: View {
    // StateObject to manage the transcription logic and state.
    // The ViewModel will persist across view updates.
    @StateObject private var viewModel = TranscriptionViewModel()

    var body: some View {
        // Vertical stack to arrange UI elements
        VStack(spacing: 20) {
            // App Title
            Text("Audio File Transcriber")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Scrollable text view to display the transcription result
            ScrollView {
                Text(viewModel.transcribedText)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
            }

            // Displays the current status of the transcription process
            Text(viewModel.statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                
            // Download button - only appears when transcription is ready
            if viewModel.isTranscriptionReady {
                Button(action: {
                    saveTranscriptionToFile()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Download Transcription")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 10)
            }

            // Button to trigger the file selection and start transcription
            Button(action: {
                // This action will open the file picker
                openFilePicker()
            }) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Select Audio File and Transcribe")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        // Request speech recognition authorization when the view appears
        .onAppear {
            viewModel.requestAuthorization()
        }
    }

    // Function to save transcription to a text file
    private func saveTranscriptionToFile() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "transcription.txt"
        savePanel.allowedContentTypes = [UTType.plainText]
        
        if savePanel.runModal() == .OK {
            guard let url = savePanel.url else { return }
            
            do {
                try viewModel.transcribedText.write(to: url, atomically: true, encoding: .utf8)
                viewModel.statusMessage = "Transcription saved successfully to \(url.lastPathComponent)"
            } catch {
                viewModel.statusMessage = "Error saving file: \(error.localizedDescription)"
            }
        }
    }
    
    // Function to open the native macOS file picker (NSOpenPanel)
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        // Define allowed audio file types
        panel.allowedFileTypes = ["m4a", "mp3", "wav", "aiff", "aifc", "caf"]

        // Handle the result of the file picker
        if panel.runModal() == .OK {
            if let url = panel.url {
                // If a file was selected, start the transcription process
                viewModel.transcribeAudio(from: url)
            }
        }
    }
}

// ViewModel to handle the speech recognition logic
@MainActor // Ensures UI updates are performed on the main thread
class TranscriptionViewModel: ObservableObject {

    // Published properties will trigger UI updates when their values change
    @Published var transcribedText: String = "Transcription will appear here..."
    @Published var statusMessage: String = "Ready. Please select an audio file."
    @Published var isTranscriptionReady: Bool = false

    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // 1. Request Authorization for Speech Recognition
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Update UI on the main thread
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.statusMessage = "Authorization granted. Ready to transcribe."
                case .denied:
                    self.statusMessage = "Speech recognition authorization denied."
                    self.transcribedText = "Please enable Speech Recognition in System Settings > Privacy & Security."
                case .restricted:
                    self.statusMessage = "Speech recognition restricted on this device."
                case .notDetermined:
                    self.statusMessage = "Speech recognition not yet authorized."
                @unknown default:
                    fatalError("Unknown authorization status.")
                }
            }
        }
    }

    // 2. Transcribe Audio from a given file URL
    func transcribeAudio(from url: URL) {
        // Cancel any previous task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Initialize the speech recognizer for the user's locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current) ?? SFSpeechRecognizer()

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            self.statusMessage = "Speech recognizer is not available for the current locale."
            return
        }
        
        // Create a recognition request from the audio file URL
        recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
        guard let request = recognitionRequest else {
            self.statusMessage = "Unable to create recognition request from the audio file."
            return
        }
        
        // Set the request to report partial results for real-time feedback
        request.shouldReportPartialResults = true
        self.transcribedText = ""
        self.statusMessage = "Transcribing..."
        self.isTranscriptionReady = false

        // 3. Start the Recognition Task
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] (result, error) in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                // Update the transcribed text with the best transcription
                self.transcribedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            // 4. Handle Errors and Completion
            if error != nil || isFinal {
                // Stop the recognition task
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                // Update status message based on the outcome
                if let error = error {
                    self.statusMessage = "Transcription failed: \(error.localizedDescription)"
                    self.isTranscriptionReady = false
                } else {
                    self.statusMessage = "Transcription finished successfully."
                    self.isTranscriptionReady = true
                }
            }
        }
    }
}


