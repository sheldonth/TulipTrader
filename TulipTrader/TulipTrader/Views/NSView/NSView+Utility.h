//
//  NSView+Utility.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PINE_ANIMATION_ROTATION_DEGREES 20.0f * M_PI / 180.0f
#define PINE_ANIMATION_TRANSLATION_DEPTH 100.0f

#pragma mark - frame modifiers

#define CGRectSetX(x, rect) (CGRectMake(x, (rect).origin.y, (rect).size.width, (rect).size.height))
#define CGRectSetY(y, rect) (CGRectMake((rect).origin.x, y, (rect).size.width, (rect).size.height))
#define CGRectSetXY(x, y, rect) (CGRectMake(x, y, (rect).size.width, (rect).size.height))
#define CGRectSetYHeight(y,height, rect) (CGRectMake((rect).origin.x, y, (rect).size.width, height))
#define CGRectSetWidth(w, rect) (CGRectMake((rect).origin.x, (rect).origin.y, w, (rect).size.height))
#define CGRectSetHeight(h, rect) (CGRectMake((rect).origin.x, (rect).origin.y, (rect).size.width, (h)))
#define CGRectSetSize(s, rect) ((CGRect){(rect).origin.x, (rect).origin.y, s})
#define CGRectFlipY(rect) (CGRectMake((rect).origin.x, -((rect).origin.y), (rect).size.width, (rect).size.height))
#define CGRectMultiply(m, rect) (CGRectMake((rect).origin.x*(m), (rect).origin.y*(m), (rect).size.width*(m), (rect).size.height*(m)))
#define CGRectRotate(rect) (CGRectMake((rect).origin.x, (rect).origin.y, (rect).size.height, (rect).size.width))

#define CGRectGetHorizontallyAlignedXCoordForWidthOnWidth(width,onWidth) floor(((onWidth) - (width)) / 2.0f)
#define CGRectGetHorizontallyAlignedXCoordForRectOnRect(rect,onRect) CGRectGetHorizontallyAlignedXCoordForWidthOnWidth(CGRectGetWidth(rect),CGRectGetWidth(onRect))
#define CGRectGetHorizontallyAlignedXCoordForViewonView(view,onView) CGRectGetHorizontallyAlignedXCoordForRectOnRect(view.frame,onView.frame)
#define CGRectSetFrameWithHorizontallyAlignedXCoordOnWidth(y,width,height,onWidth) CGRectMake(CGRectGetHorizontallyAlignedXCoordForWidthOnWidth(width,onWidth),y,width,height)
#define CGRectSetFrameWithHorizontallyAlignedXCoordOnRect(y,width,height,onRect) CGRectSetFrameWithHorizontallyAlignedXCoordOnWidth(y,width,height,CGRectGetWidth(onRect))
#define CGRectSetFrameWithHorizontallyAlignedXCoordOnView(y,width,height,onView) CGRectSetFrameWithHorizontallyAlignedXCoordOnRect(y,width,height,onView.frame)

#define CGRectGetVerticallyAlignedYCoordForHeightOnHeight(height,onHeight) floor(((onHeight) - (height)) / 2.0f)
#define CGRectGetVerticallyAlignedYCoordForRectOnRect(rect,onRect) CGRectGetVerticallyAlignedYCoordForHeightOnHeight(CGRectGetHeight(rect),CGRectGetHeight(onRect))
#define CGRectGetVerticallyAlignedYCoordForViewonView(view,onView) CGRectGetVerticallyAlignedYCoordForRectOnRect(view.frame,onView.frame)
#define CGRectSetFrameWithVerticallyAlignedYCoordOnHeight(x,width,height,onHeight) CGRectMake(x,CGRectGetVerticallyAlignedYCoordForHeightOnHeight(height,onHeight),width,height)
#define CGRectSetFrameWithVerticallyAlignedYCoordOnRect(x,width,height,onRect) CGRectSetFrameWithVerticallyAlignedYCoordOnHeight(x,width,height,CGRectGetHeight(onRect))
#define CGRectSetFrameWithVerticallyAlignedYCoordOnView(x,width,height,onView) CGRectSetFrameWithVerticallyAlignedYCoordOnRect(x,width,height,onView.frame)

#pragma mark Set origin methods
CG_INLINE void setCoords(NSView* view,CGFloat xCoord,CGFloat yCoord)
{
    [view setFrame:CGRectMake(xCoord, yCoord, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
}

CG_INLINE void setXCoord(NSView* view,CGFloat xCoord)
{
    setCoords(view, xCoord, view.frame.origin.y);
}

CG_INLINE void setYCoord(NSView* view,CGFloat yCoord)
{
    setCoords(view, view.frame.origin.x, yCoord);
}


#pragma mark Increase origin methods

CG_INLINE void increaseXCoord(NSView* view,CGFloat xIncrement)
{
    setXCoord(view, view.frame.origin.x + xIncrement);
}

CG_INLINE void increaseYCoord(NSView* view,CGFloat yIncrement)
{
    setYCoord(view, view.frame.origin.y + yIncrement);
}

CG_INLINE void increaseCoords(NSView* view,CGFloat xIncrement,CGFloat yIncrement)
{
    setCoords(view, view.frame.origin.x + xIncrement, view.frame.origin.y + yIncrement);
}

CG_INLINE void decreaseXCoord(NSView* view,CGFloat xIncrement)
{
    setXCoord(view, view.frame.origin.x - xIncrement);
}

CG_INLINE void decreaseYCoord(NSView* view,CGFloat yIncrement)
{
    setYCoord(view, view.frame.origin.y - yIncrement);
}

CG_INLINE void decrease(NSView* view,CGFloat xIncrement,CGFloat yIncrement)
{
    setCoords(view, view.frame.origin.x - xIncrement, view.frame.origin.y - yIncrement);
}

#pragma mark Set frame methods
CG_INLINE void setSize(NSView* view,CGSize size)
{
    [view setFrame:(CGRect){view.frame.origin,size}];
}

CG_INLINE void setWidthHeight(NSView* view,CGFloat width,CGFloat height)
{
    setSize(view, (CGSize){width,height});
}

CG_INLINE void setWidth(NSView* view,CGFloat width)
{
    setWidthHeight(view, width, CGRectGetHeight(view.frame));
}

CG_INLINE void setHeight(NSView* view,CGFloat height)
{
    setWidthHeight(view, CGRectGetWidth(view.frame), height);
}

CG_INLINE void ceilCoordinates(NSView* view)
{
    setCoords(view, ceilf(view.frame.origin.x), ceilf(view.frame.origin.y));
}

CG_INLINE void ceilSize(NSView* view)
{
    setWidthHeight(view, ceilf(CGRectGetWidth(view.frame)), ceilf(CGRectGetHeight(view.frame)));
}

#pragma mark Increase frame methods

CG_INLINE void increaseSize(NSView* view,CGFloat widthIncrease,CGFloat heightIncrease)
{
    setWidthHeight(view, CGRectGetWidth(view.frame) + widthIncrease, CGRectGetHeight(view.frame) + heightIncrease);
}

CG_INLINE void increaseWidth(NSView* view,CGFloat widthIncrease)
{
    setWidth(view, CGRectGetWidth(view.frame) + widthIncrease);
}

CG_INLINE void increaseHeight(NSView* view,CGFloat heightIncrease)
{
    setHeight(view, CGRectGetHeight(view.frame) + heightIncrease);
}


@interface NSView (Utility)


@end
