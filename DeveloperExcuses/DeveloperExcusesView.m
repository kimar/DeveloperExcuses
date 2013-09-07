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
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
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

@end
