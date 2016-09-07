//
//  DeveloperExcusesView.m
//  DeveloperExcuses
//
//  Created by Marcus Kida on 07.09.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//

#import "DeveloperExcusesView.h"

@interface DeveloperExcusesView()

@property NSUserDefaults *defaults;

@end

NSString *kLastFetchedQuote = @"kLastFetchedQuote";
NSString *kHtmlRegex = @"<a href=\"/\" rel=\"nofollow\" style=\"text-decoration: none; color: #333;\">(.+)</a>";

@implementation DeveloperExcusesView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];

    CGRect newFrame = self.label.frame;
    CGFloat height = [_label.stringValue sizeWithAttributes:@{NSFontAttributeName: _label.font}].height;
    newFrame.size.height = height;
    newFrame.origin.y = (NSHeight(self.bounds) - height) / 2;
    _label.frame = newFrame;

    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
}

- (void)animateOneFrame {
    [self fetchNextQuote];
}

- (BOOL)hasConfigureSheet {
    return NO;
}

- (NSWindow*)configureSheet {
    return nil;
}

- (void) initialize {
    [self setAnimationTimeInterval:0.5];
    _defaults = [NSUserDefaults standardUserDefaults];

    [self configureLabel];
    [self restoreLastQuote];
    [self fetchNextQuote];
}

- (void)configureLabel {
    _label = [[NSTextField alloc] initWithFrame:self.bounds];
    _label.autoresizingMask = NSViewWidthSizable;
    _label.alignment = NSCenterTextAlignment;

    _label.stringValue = @"Loading...";
    _label.textColor = [NSColor blackColor];
    _label.font = [NSFont fontWithName:@"Courier" size:(self.preview ? 12.0 : 24.0)];

    _label.backgroundColor = [NSColor clearColor];
    [_label setEditable:NO];
    [_label setBezeled:NO];

    [self addSubview:_label];
}

- (void)restoreLastQuote {
    self.shouldFetchQuote = YES;
    NSString *lastQuote = [_defaults valueForKey:kLastFetchedQuote];
    [self setQuote: lastQuote];
}

- (void)scheduleNextFetch {
    double delayInSeconds = 10.0;
    dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(fireTime, dispatch_get_main_queue(), ^(void){
        self.shouldFetchQuote = YES;
    });
}

- (void)setQuote:(NSString *) quote {
    if (quote != nil) {
        _label.stringValue = quote;
        [_defaults setObject:quote forKey:kLastFetchedQuote];
        [_defaults synchronize];
        self.shouldFetchQuote = NO;
        [self setNeedsDisplay:YES];
    }

    [self scheduleNextFetch];
}


- (void) fetchNextQuote {
    @synchronized (self) {
        if (!self.shouldFetchQuote) {
            return;
        }
    }

    self.shouldFetchQuote = NO;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *error;
        NSString *quote;

        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://developerexcuses.com"]];
        NSString *html = [NSString stringWithUTF8String:[data bytes]];

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kHtmlRegex options:0 error:&error];

        NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
        for (NSTextCheckingResult *match in matches) {
            quote = [html substringWithRange:[match rangeAtIndex:1]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self scheduleNextFetch];
            [self setQuote: quote];
        });
    });
}

@end
