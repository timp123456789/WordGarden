//
//  ContentView.swift
//  WordGarden
//
//  Created by Timothy Petrik on 9/17/25.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    private static let maximumGuesses = 8 //self.
    
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWordIndex = 0
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
    @FocusState private var textFieldIsFocused: Bool
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
            
                VStack(alignment: .trailing) {
                    Text("Words Guessed: \(wordsToGuess.count - wordsGuessed + wordsMissed)")
                    Text("Words Missed: \(wordsToGuess.count)")
                }
            }
            .padding(.horizontal)
            Spacer()
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
        //TODO: Switch to wordstoGuess[currentWordIndex]
            Text(revealedWord)
                .font(.title)
            
            if playAgainHidden {
                
                HStack{
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter =
                            guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let LastChar = guessedLetter.last else {
                                return
                            }
                            guessedLetter = String(LastChar).uppercased()
                        }
                        .focused($textFieldIsFocused)
                        .onSubmit {
                            guard guessedLetter != "" else {
                                return
                            }
                            guessALetter()
                            updateGamePlay()
                        }
                    
                    Button("Guess a Letter:") {
                        //TODO: Guess a letter button action here
//                        playAgainHidden = false
                        guessALetter()
                        updateGamePlay()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                
                Button(playAgainButtonLabel) {
                    //Reset after a word is guess or missed
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = Self.maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word"
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
        }
    }
    
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        revealedWord = wordToGuess.map { letter in lettersGuessed.contains(letter) ? "\(letter)" : "_"
        }.joined(separator: " ")
    }
    
    func updateGamePlay() {
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            //Animate crumbling leaf
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            //Delay it
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }
        } else {
            playSound(soundName: "correct")
        }
        
        if !revealedWord.contains("_") {
            gameStatusMessage = "You Guessed IT! It took you \(lettersGuessed.count) Guessed to Guess the word!"
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
        } else if guessesRemaining == 0 {
            gameStatusMessage = "So Sorry, You are All out of Guesses."
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {
            //TODO: Redo this with localizedstring key and inflect
            gameStatusMessage = "You have made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\n You have tried All the Words, Restart from the Beginning"
        }
        guessedLetter = ""
    }
    
    func playSound(soundName: String){
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("💔Could not read file names \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("💔Error \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
