# TMDBPreview

## Table of contents
1. [Overview](#overview)
2. [How to run](#How-to-run)
3. [Architecture](#Architecture)
4. [Libraries used](#Libraries-used)

## Overview

This is a test project developed for the needs of test assignment for [Bragi](https://bragi.com).

### Stack

This project was developed relying heavily on FRP methodologies. To this end RxSwift in combination with UIKit was used.\
Minimum deployment target for the project is iOS 14.0.

## How to run

1. Clone this GIT repo
2. Run the `pod install` command from the terminal
3. Open `TMDBPreview.xcworkspace`
4. Run the project (make sure `TMDBPreview` scheme is selected)

## Architecture

Project was deliberately designed with a minimalistic architecture, leveraging the MVVM pattern and functional reactive programming paradigm. This approach was chosen to prioritize simplicity and expedite development. More robust and production ready dependency injection solutions were not used in order to keep the project simple.  

Viewmodel is a simple function of input and output creating a stream of data between the viewmodel and view controller. Both screens are two instances of the same module differentiated only by their dependencies. The view hierarchy is created in AppDelegate where also the dependency injection occurs.

### Testing

Testability of viewmodels is achieved relatively easy since the viewmodel is a function of inputs and outputs and holds no state of its own. This makes it simple to mock dependencies and test the flow of data.

Due to time constraints a single test is created to showcase how the code is meant to be tested and the data mocked.

## Libraries used

Apart from RxSwift group of frameworks for development and testing, these ore the only libraries used in the project.

* [Kingfisher](https://github.com/onevcat/Kingfisher)\
  Kingfisher is utilised only to
  cache [poster images](https://github.com/dbekic/TMDBPreview/blob/b52b8cfc41961a490e81d9c2e9bd2065f2c7cc97/TMDBPreview/Scenes/ContentCollection/Views/Cells/ContentCollectionCell/ContentCollectionCell.swift#L73)
* [SnapKit](https://github.com/SnapKit/SnapKit)\
  Snapkit is utilised to provide more concise approach to writing autolayout constraints and to speed up the development
  process of the user interface
* [SwiftLint](https://github.com/realm/SwiftLint)\
  SwiftLint is used to enforce more constrained code quality and styling and setup can be found
  at [.swiftlint.yml](https://github.com/dbekic/TMDBPreview/blob/main/.swiftlint.yml)
