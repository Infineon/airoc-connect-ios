//
//  LCInfoView.m
//  Classes
//
//  Created by Marcel Ruegenberg on 19.11.09.

//+Copyright (C) 2012 Marcel Ruegenberg
//+
//+Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//+
//+The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//+
//+THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "LCInfoView.h"
#import "UIKit+DrawingHelpers.h"


@interface LCInfoView ()

- (void)recalculateFrame;

@end


@implementation LCInfoView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {		
        UIFont *fatFont = [UIFont boldSystemFontOfSize:12];
        
        self.infoLabel = [[UILabel alloc] init]; self.infoLabel.font = fatFont;
        self.infoLabel.backgroundColor = [UIColor clearColor]; self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        self.infoLabel.shadowColor = [UIColor blackColor];
        self.infoLabel.shadowOffset = CGSizeMake(0, -1);
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.infoLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init {
	if((self = [self initWithFrame:CGRectZero])) {
		;
	}
	return self;
}

#define TOP_BOTTOM_MARGIN 5
#define LEFT_RIGHT_MARGIN 15
#define SHADOWSIZE 3
#define SHADOWBLUR 5
#define HOOK_SIZE 8

void CGContextAddRoundedRectWithHookSimple(CGContextRef c, CGRect rect, CGFloat radius) {
	//eventRect must be relative to rect.
	CGFloat hookSize = HOOK_SIZE;
	CGContextAddArc(c, rect.origin.x + radius, rect.origin.y + radius, radius, M_PI, M_PI * 1.5, 0); //upper left corner
	CGContextAddArc(c, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, M_PI * 1.5, M_PI * 2, 0); //upper right corner
	CGContextAddArc(c, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI * 2, M_PI * 0.5, 0);
    {
		CGContextAddLineToPoint(c, rect.origin.x + rect.size.width / 2 + hookSize, rect.origin.y + rect.size.height);
		CGContextAddLineToPoint(c, rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height + hookSize);
		CGContextAddLineToPoint(c, rect.origin.x + rect.size.width / 2 - hookSize, rect.origin.y + rect.size.height);
	}
	CGContextAddArc(c, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI * 0.5, M_PI, 0);
	CGContextAddLineToPoint(c, rect.origin.x, rect.origin.y + radius);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self sizeToFit];
    
    [self recalculateFrame];
    
    [self.infoLabel sizeToFit];
    self.infoLabel.frame = CGRectMake(self.bounds.origin.x + 7, self.bounds.origin.y + 2, self.infoLabel.frame.size.width, self.infoLabel.frame.size.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    // TODO: replace with new text APIs in iOS 7 only version
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize s = [self.infoLabel.text sizeWithFont:self.infoLabel.font];
#pragma clang diagnostic pop
    s.height += 15;
    s.height += SHADOWSIZE;
    
    s.width += 2 * SHADOWSIZE + 7;
    s.width = MAX(s.width, HOOK_SIZE * 2 + 2 * SHADOWSIZE + 10);
    
    return s;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();

	CGRect theRect = self.bounds;
	//passe x oder y Position sowie Hoehe oder Breite an, je nachdem, wo der Hook sitzt.
	theRect.size.height -= SHADOWSIZE * 2;
	theRect.origin.x += SHADOWSIZE;
	theRect.size.width -= SHADOWSIZE * 2;
    theRect.size.height -= SHADOWSIZE * 2;
	
    [[UIColor colorWithWhite:0.0 alpha:1.0] set];
	CGContextSetAlpha(c, 0.7);

	CGContextSaveGState(c);
	
    CGContextSetShadow(c, CGSizeMake(0.0, SHADOWSIZE), SHADOWBLUR);
	
	CGContextBeginPath(c);
    CGContextAddRoundedRectWithHookSimple(c, theRect, 7);
	CGContextFillPath(c);
	
    [[UIColor whiteColor] set];
	theRect.origin.x += 1;
	theRect.origin.y += 1;
	theRect.size.width -= 2;
	theRect.size.height = theRect.size.height / 2 + 1;
	CGContextSetAlpha(c, 0.2);
    CGContextFillRoundedRect(c, theRect, 6);
}



#define MAX_WIDTH 400
// calculate own frame to fit within parent frame and be large enough to hold the event.
- (void)recalculateFrame {
    CGRect theFrame = self.frame;
    theFrame.size.width = MIN(MAX_WIDTH, theFrame.size.width);
    
    CGRect theRect = self.frame; theRect.origin = CGPointZero;

    {
        theFrame.origin.y = self.tapPoint.y - theFrame.size.height + 2 * SHADOWSIZE + 1;
        theFrame.origin.x = round(self.tapPoint.x - ((theFrame.size.width - 2 * SHADOWSIZE)) / 2.0);
    }
    self.frame = theFrame;
}

@end
