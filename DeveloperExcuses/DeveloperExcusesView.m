//
//  DeveloperExcusesView.m
//  DeveloperExcuses
//
//  Created by Marcus Kida on 07.09.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//

#import "DeveloperExcusesView.h"

@implementation DeveloperExcusesView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    NSSize s = [self.label.stringValue sizeWithAttributes:@{NSFontAttributeName: self.label.font}];
    CGRect rl = self.label.frame;
    rl.size.height = s.height;
    rl.origin.y = rect.size.height/2;
    self.label.frame = rl;
    self.label.textColor = [NSColor blackColor];

    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
}

- (void)animateOneFrame
{
    if(!self.locked)
    {
        self.locked = YES;
        [self getRandomQuote];
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.locked = NO;
        });
    }
    
    self.needsDisplay = YES;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void) initialize
{
    [self setAnimationTimeInterval:1/30.0];

    self.label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, 100)];
    self.label.autoresizingMask = NSViewWidthSizable;
    self.label.alignment = NSCenterTextAlignment;
    self.label.backgroundColor = [NSColor clearColor];
    [self.label setEditable:NO];
    [self.label setBezeled:NO];
    self.label.textColor = [NSColor blackColor];
    self.label.font = [NSFont fontWithName:@"Courier" size:24.0];
    self.label.stringValue = @"Loading...";
    [self addSubview:self.label];
    [self getRandomQuote];
}

- (void) getRandomQuote
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *html = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://developerexcuses.com"]];
        NSString *string = [NSString stringWithUTF8String:[html bytes]];
        NSArray *parts = [string componentsSeparatedByString:@"<a href=\"/\" rel=\"nofollow\" style=\"text-decoration: none; color: #333;\">"];
        NSString *newString = [parts objectAtIndex:1];
        NSArray *newParts = [newString componentsSeparatedByString:@"</a>"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.stringValue = [newParts objectAtIndex:0];
        });
    });
}

@end
