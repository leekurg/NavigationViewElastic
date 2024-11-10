# NavigationViewElastic
`NavigationViewElastic` is a `View` that mimics system `NavigationView` + `ScrollView` to add ability to use custom content under the navigation bar title. Requires  **iOS v15**.

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
Customize style of navigation bars within your app and even provide new capabitilities to them by adding customizable, resizable and interactive content to navigation bars bottom. All of it with convenient and powerful SwiftUI-styled API, color scheme and orientation support!

### Features
1. Transparent navigation bar similar to system one's behaviour
2. Apply any background style to navigation bar
3. Add custom interactive resizable content to navigation bar's bottom
4. Add custom content as leading or trailing toolbar items
5. Control bar's title display behaviour with appropriate mode (`large`, `inline` or `auto`)
6. Full contol of any size, padding and spacing through `Config` handy API 
7. Supports device's color scheme
8. Supports device's orientation
9. Configurable **NVE**'s content and bar items safe areas
10. Optional *Back button* to use when NVE is nested in navigation hierarchy
11. Editable configuration struct determines sizes of basic elements
12. UDF-like API for «*Pull-to-refresh*» - you pass a closure to call after pull-gesture. When work is done, pass a `Bool` to **NavigationViewElastic** to hide progress indicator. When no closure is passed, progress indicator will not appear on pull-gesture.

### Usage
You can use example project located here: [NavigationViewElastic Example](https://github.com/leekurg/NavigationViewElasticExample).

Annotate `SwiftUI` file with «**import NavigationViewElastic**». Then pass to **NavigationViewElastic** a `content` with your main content, `subtitleContent` with additional view for displaying at the bottom of navigation bar. Optionaly, you can use `leadingBarItem` and `trailingBarItem` viewbuilders or modifier-like functions: `.refreshable()` for *Pull-to-refresh* ability, `.navigationTitle()` and `blurStyle()`.

For using **NVE** as nested view inside your navigation hierarchy you can optionally add a *Back button* to navigation toolbar. You can pick a system-like button `NVE.BackButton()`, style it with custom title string, action or foreground color, or make your own view. When using **NVE** as nested navigation view, remember to hide outer `NavigationView` with `.navigationBarHidden(true)`.
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
}
```

#### Wrapping in NavigationStack
Since `NavigationViewElastic` is a `View`, you can use it within `NavigationStack`(or within `NavigationView` for older systems) as any other view. Check out how such navigation chain might look like:

<p align="center">
    <img src="https://github.com/user-attachments/assets/06732307-0bc4-4ec1-b128-c1bf537b4db9" width="250">
</p>

As you can see, first and fourth screens displaying vanilla navigation titles, while second and third screens is displaying customized `NavigationViewElastic` titles. To achieve such smooth behaviour, you have to hide system's navigation bar for any **NVE** screen within navigation sequence by adding to it code:

```
NavigationViewElastic {
    ...
}
.toolbar(.hidden, for: .navigationBar)
```

Also, if you want *swipe-back* gesture to work on **NVE** screens, you need to implement this extension within your project (thanks to [this guy](https://stackoverflow.com/a/68650943)):

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

