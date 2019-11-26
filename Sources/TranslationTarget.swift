//
//  Copyright © 2019 FINN.no. All rights reserved.
//

import CoreGraphics

/// Model defining a certain area of a BottomSheetView.
///
protocol TranslationTarget {

    /// An offset which a BottomSheetView can transition to
    ///
    var targetOffset: CGFloat { get }

    /// Flag specifying whether a BottomSheetView should be dismissed.
    /// This should only be used when presented by a presentation controller
    ///
    var isDismissible: Bool { get }

    /// BottomSheetView will find the model which contains the current translation offset
    /// and transition to its target offset when its gesture ends.
    ///
    /// - Parameters:
    ///   - offset: some offset. E.g. a pan gestures translation, a table view's contentOffset.
    ///
    /// Return true if a BottomSheetView should transition to this target offset.
    ///
    func contains(offset: CGFloat) -> Bool

    /// This method is called when a BottomSheetView's pan gesture changes.
    ///
    /// - Parameters:
    ///   - offset: some offset. E.g. a pan gesture's translation, a table views contentOffset.
    ///
    /// BottomSheetView calls this method to set the constant of its constraint
    /// Use this method to alter the panning movement of a BottomSheetView. E.g. make it bounce, or stick to a value.
    ///
    func nextOffset(for offset: CGFloat) -> CGFloat
}

/// Defines the behavior of the translation
enum TranslationBehavior {
    case linear
    case rubberBand(radius: CGFloat)
    case stop
}

/// RangeTarget has an upper and a lower bound defining a range around its target offset
///
struct RangeTarget: TranslationTarget {
    let targetOffset: CGFloat
    let range: Range<CGFloat>
    let isDismissible: Bool

    func contains(offset: CGFloat) -> Bool {
        range.contains(offset)
    }

    func nextOffset(for offset: CGFloat) -> CGFloat {
        offset
    }
}

/// LimitTarget will compare the offset against its bound
///
/// A lower limit model will stop a BottomSheetView translating below its lowest target offset
///
///     let lowerLimit = LimitModel(
///         targetOffset: offset,
///         bound: offset,
///         behavior: .stop,
///         isDismissable: false,
///         compare: <
///     )
///
struct LimitTarget: TranslationTarget {
    let targetOffset: CGFloat
    let bound: CGFloat
    let behavior: TranslationBehavior
    let isDismissible: Bool
    let compare: (CGFloat, CGFloat) -> Bool

    func contains(offset: CGFloat) -> Bool {
        compare(offset, bound)
    }

    func nextOffset(for offset: CGFloat) -> CGFloat {
        switch behavior {
        case .linear:
            return offset
        case .rubberBand(let radius):
            let distance = offset - bound
            let newOffset = radius * (1 - exp(-abs(distance) / radius))

            if distance < 0 {
                return bound - newOffset
            } else {
                return bound + newOffset
            }

        case .stop:
            return bound
        }
    }
}
