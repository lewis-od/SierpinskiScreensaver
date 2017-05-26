//
//  sierpinski_saverView.m
//  sierpinski_saver
//
//  Created by Lewis O'Driscoll on 27/04/2017.
//  Copyright © 2017 Lewis O'Driscoll. All rights reserved.
//

#import "sierpinski_saverView.h"

@implementation sierpinski_saverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    
    iterations = 0;
    lastPointAdded = [NSDate date];
    
    // Find centre of screen
    NSRect screenSize = [self bounds];
    float centreX = NSMaxX(screenSize)/2;
    float centreY = NSMaxY(screenSize)/2;
    
    // Add initial 3 points
    triangleHeight = centreY * 0.8;
    NSValue *A = [NSValue valueWithPoint:
                  NSMakePoint(centreX, centreY + triangleHeight)];
    
    NSValue *B = [NSValue valueWithPoint:
                  NSMakePoint(centreX - ((2*triangleHeight)/sqrt(3)), // sqrt(3)=tan(π/3)
                              centreY - triangleHeight)];
    
    NSValue *C = [NSValue valueWithPoint:
                  NSMakePoint(centreX + ((2*triangleHeight)/sqrt(3)), // sqrt(3)=tan(π/3)
                              centreY - triangleHeight)];
    
    
    points = [[NSMutableArray alloc] initWithObjects:A, B, C, nil];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    NSRect screenSize = [self bounds];
    float pointWidth = NSMaxY(screenSize) / 200;
    
    [[NSColor whiteColor] set];
    
    NSString *numIterations = [NSString stringWithFormat:@"%i",
                               (int)[points count]];
    
    float centreX = NSMaxX(screenSize)/2;
    float centreY = NSMaxY(screenSize)/2;
    
    [self drawText:numIterations atPoint:
     NSMakePoint(centreX, centreY - triangleHeight/4)];
    
    for (NSValue *point in points) {
        NSPoint toDraw = [point pointValue];
        [[NSBezierPath bezierPathWithOvalInRect:
          NSMakeRect(toDraw.x, toDraw.y, pointWidth, pointWidth)] fill];
    }
    
}

- (void)drawText:(NSString *)textString atPoint:(NSPoint)centre
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSFont fontWithName:@"Helvetica" size:20],
                                NSFontAttributeName, [NSColor whiteColor],
                                NSForegroundColorAttributeName, nil];
    
    NSAttributedString *label = [[NSAttributedString alloc]
                                 initWithString:textString
                                     attributes:attributes];
    
    float textX = centre.x - label.size.width/2;
    float textY = centre.y - label.size.height/2;
    [label drawAtPoint:NSMakePoint(textX, textY)];
}

- (void)animateOneFrame
{
    // Add a point if it's been more than 0.1 secs
    if ([lastPointAdded timeIntervalSinceNow] < -0.01)
    {
        NSPoint newPoint = [self createNewPoint];
        [points addObject:[NSValue valueWithPoint:newPoint]];
        lastPointAdded = [NSDate date];
    }
    
    [self setNeedsDisplay:YES];
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

#pragma mark Movement Logic

- (CGPoint)createNewPoint
{
    int pointNumber  = SSRandomIntBetween(0, 2);
    
    CGPoint towards = [points[pointNumber] pointValue];
    CGPoint last = [[points lastObject] pointValue];
    
    if (towards.x == last.x && towards.y == last.y)
    {
        return [self createNewPoint];
    }
    
    float dx = (towards.x - last.x) / 2;
    float dy = (towards.y - last.y) / 2;
    
    return NSMakePoint(last.x + dx, last.y + dy);
}

@end
