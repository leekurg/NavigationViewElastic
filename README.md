# NavigationViewElastic
Mimic of `NavigationView` + `ScrollView`, with ability to add any content under title of top bar. Support for **iOS v15 and higher**

<p align="center">
    <img src="https://github.com/leekurg/NavigationViewElastic/assets/105886145/18298e5c-9bbc-4ecd-b454-5ff2937eb845" width="300">
</p>

### Overview
Ever struggle to put some custom `SwiftUI` view inside of bar of system `NavigationView`?
Well, I struggled that too, so I came up with the solution. My goal was to imitate system navigation bar(or at least what it was up to iOS 17) as much as possible with ability to add some custom content to it's bottom, and reach that goal with pure `SwiftUI`.

### Details
Repository includes a package with **NavigationViewElastic** for install. You can use example project located here: [NavigationViewElastic Example](https://github.com/leekurg/NavigationViewElasticExample).

### Features
1. Transparent navigation bar similar to system one's behaviour, support current device theme
2. Ability to add any content you want at navigation’s bar bottom placement
3. Optional *Back button* to use when NVE is nested in navigation hierarchy
4. Editable configuration struct determines sizes of basic elements
5. UDF-like API for «*Pull-to-refresh*» - you pass a closure to call after pull-gesture. When work is done, pass a `Bool` to **NavigationViewElastic** to hide progress indicator. When no closure is passed, progress indicator will not appear on pull-gesture.

### Install
`SPM` installation: in **Xcode** tap «**File → Add packages…**», paste is search field the URL of this page and press «**Add package**».

### Usage
Annotate `SwiftUI` file with «**import NavigationViewElastic**». Then pass to **NavigationViewElastic** a `content` with your main content, `subtitleContent` with additional view for displaying at the bottom of navigation bar. Optionaly, you can use `leadingBarItem` and `trailingBarItem` viewbuilders or modifier-like functions: `.refreshable()` for *Pull-to-refresh* ability, `.navigationTitle()` and `blurStyle()`.

For using **NVE** as nested view inside your navigation hierarchy you can optionally add a *Back button* to navigation toolbar. You can pick a system-like button `NVE.BackButton()`, style it with custom title string, action or foreground color, or make your own view. When using **NVE** as nested navigation view, remember to hide outer `NavigationView` with `.navigationBarHidden(true)`.
```
var body: some View {
        NavigationViewElastic {
            VStack {
                ///...
            }
        } subtitleContent: {
            Button("Subtitle button") { }
        } trailingBarItem: {
            Button("Bar button") { }
        }
        .navigationTitle("Title")
        .refreshable(stopRefreshing: .constant(false), onRefresh: { } )
    }
}
```
