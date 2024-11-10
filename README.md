# NavigationViewElastic
`NavigationViewElastic` is a SwiftUI `View` that replicates the behavior of navigation bar for the system `NavigationView` combined with `ScrollView`, while adding the capability to use custom content beneath the navigation bar title. Requires **iOS 15** or later.

<table>
    <tbody>
        <tr>
            <td> <p align="center"> <strong>Portrait</strong> </p> </td>
            <td> <p align="center"> <strong>Landscape</strong> </p> </td>
        </tr>
        <tr>
            <td>
              <img src="https://github.com/user-attachments/assets/70497361-57d8-461a-a497-3d917469e236" width="250">
            </td>
            <td>
              <img src="https://github.com/user-attachments/assets/e2bac2e4-d187-42c0-94e5-871d811915a5" width="500">
            </td>
        </tr>
    </tbody>
</table>

### What is NavigationViewElastic
`NavigationViewElastic` is not meant to replace `NavigationStack` or `NavigationView`, nor does it propose alternative navigation flows. Instead, it offers a way to create customizable navigation bars for specific parts of your app where enhanced interactivity and visual appeal are desired. **NVE** adds new functionality by enabling interactive, resizable, and customizable content at the bottom of the navigation bar. This is achieved through a simple, SwiftUI-friendly API, with full support for color schemes and device orientation.

### Features
1. **Transparent Navigation Bar**: Mimics the behavior of the system navigation bar.
2. **Custom Background Styles**: Apply any background style to the navigation bar.
3. **Interactive, Resizable Content**: Add custom content at the bottom of the navigation bar.
4. **Custom Toolbar Items**: Easily add leading or trailing toolbar items.
5. **Title Display Control**: Adjust the navigation bar title's display mode (`large`, `inline`, or `auto`).
6. **Editable Configurationl**: Configure sizes, padding, and spacing using a simple `NVE.Config` API.
7. **Integration with Vanilla Navigation** Smooth integration with emdedded `NavigationStack`/`NavigationView`
8. **Color Scheme Support**: Automatically adapts to the device's light or dark mode.
9. **Orientation Support**: Works seamlessly in both portrait and landscape orientations.
10. **Safe Area Configuration**: Customize the safe areas for **NavigationViewElastic** content. Bar items respects device's safe area.
11. **Optional Back Button**: Include a `NVE.BackButton` when **NavigationViewElastic** is nested in a navigation hierarchy.
13. **Pull-to-Refresh API**: Implement pull-to-refresh functionality using a closure. When the task is complete, provide a `Bool` to hide the progress indicator. If no closure is passed, the progress indicator will not be shown.

### Usage
You can use example project located here: [NavigationViewElastic Example](https://github.com/leekurg/NavigationViewElasticExample).

```
var body: some View {
    NavigationViewElastic {
        VStack {
            ///...
        }
        .nveTitle("Title")
        .nveTitleDisplayMode(.inline)    // Navigation bar title appears in minimized form
    } subtitleContent: {
        Button("Subtitle button") { }
    } leadingBarItem: {
        NVE.BackButton()                 // Back button for leading bar placement
    } trailingBarItem: {
        Button("Bar button") { }         // Button for trailing bar placement
    }
    .refreshable(stopRefreshing: .constant(false), onRefresh: { } )    // Perform action on swipe-to-refresh gesture
    .nveConfig { config in
        config.barCollapsedStyle = AnyShapeStyle(.ultraThinMaterial)    // Style bar's background in collapsed form
    }
}
```

#### Title Display Modes

With `.nveTitleDisplayMode()`, you can control how the navigation bar's title is displayed. There are three modes available:

1. **`large`**: The title is initially displayed in a large format and collapses into a smaller title as you scroll down.
2. **`inline`**: The title always appears in its small form.
3. **`auto`**: This is the default mode, where the title appears in `large` form in portrait orientation and switches to `inline` in landscape orientation.

#### Config

**NavigationViewElastic** relies on `NVE.Config` to configure various aspects, such as sizes, padding, and spacing. The `NVE.Config` is set in the 
`SwiftUI` Environment and affects all **NavigationViewElastic** instances down the view hierarchy. You can use a convenient view extension to customize the `NVE.Config`:

```swift
.nveConfig { config in
    config.barCollapsedStyle = AnyShapeStyle(.red)    /// Applies a red background color to the bar when collapsed
    config.largeTitle.topEdgeInset = 10               /// Sets the top edge inset for the large title
    config.smallTitle.topPaddingPortrait = 5          /// Sets the top padding for the small title in portrait mode
    config.contentIgnoresSafeAreaEdges = .horizontal  /// NVE content will ignore horizontal safe area insets
    ...
}
```

#### Wrapping in NavigationStack
Since `NavigationViewElastic` is a `View`, you can use it within a `NavigationStack` (or within `NavigationView` for older systems) just like any other view. Here's an example of how a navigation chain might look:

<p align="center">
    <img src="https://github.com/user-attachments/assets/06732307-0bc4-4ec1-b128-c1bf537b4db9" width="250">
</p>

In this example, the first and fourth screens display standard navigation titles, while the second and third screens showcase customized `NavigationViewElastic` titles. To achieve this smooth transition behavior, make sure to hide the system navigation bar on any **NVE** screen within the navigation sequence by adding the following code:

```
NavigationViewElastic {
    ...
}
.toolbar(.hidden, for: .navigationBar)
```
Additionally, if you want the *swipe-back* gesture to work on **NVE** screens, you need to implement this extension in your project (credit to [this answer](https://stackoverflow.com/a/68650943)):

```
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
```

### Install
`SPM` installation: in **Xcode** tap «**File → Add packages…**», paste is search field the URL of this page and press «**Add package**».

#### Roadmap
## Roadmap
- [x] Landscape orientation
- [x] Title display modes
- [x] Hideable subtitle content
- [x] Handy config API
- [x] Safe area
- [ ] Custom title content
- [ ] Searchable
- [ ] Hide subtitle on scroll option

