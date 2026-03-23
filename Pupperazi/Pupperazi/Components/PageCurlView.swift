import SwiftUI

/// A SwiftUI wrapper around `UIPageViewController` with `.pageCurl` transition.
///
/// Provides a magazine-style page curl effect for flipping through content.
struct PageCurlView<Content: View>: UIViewControllerRepresentable {
    let pageCount: Int
    @Binding var currentPage: Int
    var orientation: UIPageViewController.NavigationOrientation = .horizontal
    let content: (Int) -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: orientation,
            options: [.spineLocation: UIPageViewController.SpineLocation.min.rawValue]
        )
        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator
        pageVC.view.backgroundColor = .clear

        // Make page curl gesture recognizers require horizontal movement,
        // so vertical scrolling can pass through to the parent ScrollView.
        for gestureRecognizer in pageVC.gestureRecognizers {
            if let panGR = gestureRecognizer as? UIPanGestureRecognizer {
                panGR.delegate = context.coordinator
            }
        }

        // Set initial page
        let initialVC = context.coordinator.makeHostingController(for: currentPage)
        pageVC.setViewControllers([initialVC], direction: .forward, animated: false)

        return pageVC
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        // Keep coordinator's parent reference fresh so content closure is up-to-date
        context.coordinator.parent = self

        guard let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Content> else { return }

        // Always refresh the current page's rootView so data changes propagate
        currentVC.rootView = content(currentVC.pageIndex)

        // If the page index changed externally (e.g. from a binding), navigate to it
        if currentVC.pageIndex != currentPage {
            let direction: UIPageViewController.NavigationDirection = currentPage > currentVC.pageIndex ? .forward : .reverse
            let newVC = context.coordinator.makeHostingController(for: currentPage)
            pageVC.setViewControllers([newVC], direction: direction, animated: true)
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
        var parent: PageCurlView

        init(_ parent: PageCurlView) {
            self.parent = parent
        }

        func makeHostingController(for index: Int) -> IndexedHostingController<Content> {
            let vc = IndexedHostingController(rootView: parent.content(index))
            vc.pageIndex = index
            vc.view.backgroundColor = .clear
            return vc
        }

        // MARK: Gesture Delegate

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            // Only begin if the gesture is more horizontal than vertical
            return abs(velocity.x) > abs(velocity.y)
        }

        // MARK: Data Source

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let vc = viewController as? IndexedHostingController<Content> else { return nil }
            let previousIndex = vc.pageIndex - 1
            guard previousIndex >= 0 else { return nil }
            return makeHostingController(for: previousIndex)
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let vc = viewController as? IndexedHostingController<Content> else { return nil }
            let nextIndex = vc.pageIndex + 1
            guard nextIndex < parent.pageCount else { return nil }
            return makeHostingController(for: nextIndex)
        }

        // MARK: Delegate

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed,
                  let currentVC = pageViewController.viewControllers?.first as? IndexedHostingController<Content> else { return }
            let newIndex = currentVC.pageIndex
            guard newIndex >= 0 && newIndex < parent.pageCount else { return }
            parent.currentPage = newIndex
        }
    }
}

/// A UIHostingController that tracks its page index.
class IndexedHostingController<Content: View>: UIHostingController<Content> {
    var pageIndex: Int = 0
}
