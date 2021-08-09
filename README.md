# StepperView overview

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

StepperView is a simple view that provides an interactive step-type progress bar to make it visually easier to keep track of the current position in the sequence of steps.

# _Installing the `StepperView`_
Installing the `StepperView` is possible with `Swift Package Manager (SPM)`
### <u>_Swift Package Manager (SPM)_</u>
The [Swift Package Manager](https://swift.org/package-manager/) is a dependency manager integrated into the `swift` compiler and `Xcode`.

To integrate `StepperView` into an Xcode project, go to the project editor, and select `Swift Packages`. From here hit the `+` button and follow the prompts using  `https://github.com/streamsoftstudio/StepperView.git` as the URL.

To include `StepperView` in a Swift package, simply add it to the dependencies section of your `Package.swift` file. And add the product `StepperView` as a dependency for your targets.

```Swift
dependencies: [
	.package(url: "https://github.com/streamsoftstudio/StepperView.git", .upToNextMinor(from: "1.0.0"))
]
```
# _Using the `StepperView`_
In order to use `StepperView` in your application, there are a few steps that you would need to take.

## **_Initialization_**
If you're using Storyboards, add a class `StepperView` to the UIView element and set the module to `StepperView`.
Programmatically you just instantiate the `StepperView` as usual after adding import statement:
```Swift
import StepperView
```

## **_Implementation_**
In order to populate the steps, call the 

`loadSteps(_ steps: [StepperView.StepperViewStepDisplayable?])` 

method after initialization. This method accepts an array of elements that conform to `StepperViewStepDisplayable`, which only has one requirement, which is a `title: String` property.

In order to receive callbacks for the selected button, please conform to `StepperViewNavigationDelegate` and implement the delegate method 

`shouldNavigateToStep(_ step: StepperView.StepView)` 

which has the argument of the `StepperView.StepView` that has been selected.

The Public API exposes few methods and properties that you can utilize:
- _UI preferences_

    `axis` - _possible orientations are `.vertical` & `.horizontal` (defaults to `.vertical` if not set)_

    `activeColor` - _a color for the active step (defaults to `UIColor.blue` if not set)_

    `inactiveColor` - _a color for the inactive step (defaults to `UIColor.lightGray` if not set)_

    `stepShape` - _a shape of the step image (defaults to `.circular` if not set)_

- _Navigation_

    The following 2 methods are used to navigate through steps in sequence. Usually called from a button (e.g. Next/Previous button), without direct interaction with the steps.

    `nextItem(_ completion: (Bool) -> ())`

    `previousItem(_ completion: (Bool) -> ())`

    Both if these methods will call the delegate method `shouldNavigateToStep` and will affect the UI state of the steps. 
    In case you would like to modify the active state on manual interaction with the step, please call the 

    `setSelected(_ step: StepperView.StepView)` 

    method on a selected step.


