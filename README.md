# NavigationViewElastic
Mimic of `NavigationView` + `ScrollView`, with ability to add any content under title of top bar.

<p align="center">
    <img src="https://github.com/leekurg/NavigationViewElastic/assets/105886145/294a60f7-ba43-4360-954e-96c9dd11158f" width="300">
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
- All passing content is `AnyView` due to performance reasons: to `SwiftUI` trying redrawing it on any scroll changes 😓

### Install
`SPM` installation: in **Xcode** tap «**File → Add packages…**», paste is search field the URL of this page and press «**Add package**».

### Usage
Annotate `SwiftUI` file with «**import NavigationViewElastic**». Then pass a `content` variable with your main content, `subtitleContent` with additional view for displaying at the bottom of navigation bar, and, optionaly, `onRefresh()` closure and `stopRefreshing` value if you need *Pull-to-refresh* ability.

```
var body: some View {
        NavigationViewElastic(
            title: «Some title»,
            content: content,
            subtitleContent: subtitleContent,
            primaryActionLabel: primaryActionLabel,
            stopRefreshing: $stopRefreshing,
            onRefresh: {
                //on refresh actions
            }
        )
    }
}
```
