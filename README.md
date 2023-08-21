# NavigationViewElastic
Mimic of `NavigationView` + `ScrollView`, with ability to add any content under title of top bar.

<p align="center">
    <img src="https://github.com/leekurg/NavigationViewElastic/assets/105886145/1a3d93de-2cef-4204-94b0-202b16337b35" width="300">
</p>

### Overview
Ever struggle to put some custom `SwiftUI` view inside of bar of system `NavigationView`?
Well, I struggled that too, so I came up with the solution. My goal was to imitate system navigation bar(or at least what it was up to iOS 17) as much as possible with ability to add some custom content to it's bottom, and reach that goal with pure `SwiftUI`.

### Details
Repository includes a package with **NavigationViewElastic** for install and project with example of usage.

### Features
1. Transparent navigation bar similar to system one's behaviour, support current device theme
2. Ability to add any content you want at navigation’s bar bottom placement
3. UDF-like API for «*Pull-to-refresh*» - you pass a closure to call after pull-gesture. When work is done, pass a `Bool` to **NavigationViewElastic** to hide progress indicator. When no closure is passed, progress indicator will not appear on pull-gesture.

### Limitations
- When `content`'s height is lesser than screen size - content is unable to scroll up 😓

### Install
`SPM` installation: in **Xcode** tap «**File → Add packages…**», paste is search field the URL of this page and press «**Add package**».

### Usage
Annotate `SwiftUI` file with «**import NavigationViewElastic**». Then pass to **NavigationViewElastic** a `content` `@ViewBuilder` with your main content, `subtitleContent` `@ViewBuilder` with additional view for displaying at the bottom of navigation bar. Optionaly, you can use modifier-like functions to configure component: `.refreshable()` for *Pull-to-refresh* ability, `.navigationTitle()` and `blurStyle()`.

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
