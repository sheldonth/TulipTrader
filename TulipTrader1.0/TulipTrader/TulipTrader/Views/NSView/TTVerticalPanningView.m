//
//  TTVerticalPanningView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/9/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTVerticalPanningView.h"
#import "TTVerticalOBView.h"
#import "RUConstants.h"
#import "TTRulerView.h"

@interface TTVerticalPanningView()

@property(nonatomic, retain)TTVerticalOBView* graphView;
@property(nonatomic, retain)NSTrackingArea* trackingArea;
@property(nonatomic)CGPoint lastClickPt;
@property(nonatomic)CGPoint originalOrigin;
@property(nonatomic, retain)TTRulerView* _horizontalRuler;
@property(nonatomic, retain)TTRulerView* _verticalRuler;

@end

@implementation TTVerticalPanningView

//+(Class)rulerViewClass
//{
//    return [TTRulerView class];
//}

-(void)mouseUp:(NSEvent *)theEvent
{
    [self.contentView setDocumentCursor:[NSCursor openHandCursor]];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    _lastClickPt = [theEvent locationInWindow];
    _originalOrigin = [self.contentView bounds].origin;
    [self.contentView setDocumentCursor:[NSCursor closedHandCursor]];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint newPoint = [theEvent locationInWindow];
    NSPoint newOrigin = NSMakePoint(self.originalOrigin.x, self.originalOrigin.y +
                                    (self.lastClickPt.y - newPoint.y));
    [self.contentView scrollToPoint: [self.contentView constrainScrollPoint: newOrigin]];
    [self reflectScrolledClipView: self.contentView];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    [self.contentView setDocumentCursor:[NSCursor openHandCursor]];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setGraphView:[[TTVerticalOBView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(frame), 3 * CGRectGetHeight(frame)}]];
        
        [self setDocumentView:_graphView];
        
        [self setHasVerticalScroller:YES];
        
        [self setTrackingArea:[[NSTrackingArea alloc]initWithRect:frame options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved+NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag) owner:self userInfo:nil]];
        
        [self addTrackingArea:_trackingArea];
        
//        [self set_verticalRuler:[[TTRulerView alloc]initWithScrollView:self orientation:NSVerticalRuler]];
//        
//        [self set_horizontalRuler:[[TTRulerView alloc]initWithScrollView:self orientation:NSHorizontalRuler]];
//        
//        [self setHorizontalRulerView:__horizontalRuler];
//        
//        [self setVerticalRulerView:__verticalRuler];
//        
//        [self setHasVerticalRuler:YES];
//        
//        [self setHasHorizontalRuler:YES];
//        
//        [self setRulersVisible:YES];
        
//        [NSScrollView setRulerViewClass:[TTRulerView class]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

@end
