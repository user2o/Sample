# Sample App

## Intro

This is a small sample app is written entirely in Swift. Most of the UI is built with **UIKit** using **Auto Layout**, but there is also a part **SwiftUI** in it. You can toggle which UI will be used by stepping into the settings. The network code is based on the native **URLSession**s and the wrapper **Just**, to show them both off. 

This sample app features
- a simple RSS reader using **SafariViewController** to read articles (in reader mode by default)
- a simple OMDBAPI.com **API integration** *(you'll need a key to access the api)*
- a **configuration** of
  - the RSS feed url
  - the OMDB API key
  - grayscaling of images of read articles
  - whether or not to use the SwiftUI parts

You can also watch this video to see how the app looks like in general, although it may not be up to the code yet:

[![Demo Readme Video](http://media.gettyimages.com/vectors/play-icon-in-circle-media-player-control-button-vector-vector-id908327012?s=170x170)](https://odium.keybase.pub/club/README_480.mp4 "Play Video!")

## Installation

1. Clone the repo, obviously.
2. run `pod install` to install all dependencies.
3. Open the XCWorkspace file.
4. Select a Team and unique bundle identifier for signing.
5. Run!
