//
//  LCLegendView.m
//  ios-linechart
//
//  Created by Marcel Ruegenberg on 02.08.13.

//+Copyright (C) 2012 Marcel Ruegenberg
//+
//+Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//+
//+The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//+
//+THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "LCLegendView.h"
#import "UIKit+DrawingHelpers.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation LCLegendView
@synthesize titlesFont=_titlesFont;

#define COLORPADDING 15
#define PADDING 5

- (void)drawRect:(CGRect)rect {
    

}

- (UIFont *)titlesFont {
    if(_titlesFont == nil)
        _titlesFont = [UIFont boldSystemFontOfSize:10];
    return _titlesFont;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = [self.titlesFont lineHeight] * [self.titles count];
    CGFloat w = 0;
    for(NSString *title in self.titles) {
        // TODO: replace with new text APIs in iOS 7 only version
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize s = [title sizeWithFont:self.titlesFont];
#pragma clang diagnostic pop
        w = MAX(w, s.width);
    }
    return CGSizeMake(COLORPADDING + w + 2 * PADDING, h + 2 * PADDING);
}

@end
