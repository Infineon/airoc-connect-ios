//
//  MRHexKeyboard.m
//
//  Created by Mikk Rätsep on 02/10/13.
//  Copyright (c) 2013 Mikk Rätsep. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "MRHexKeyboard.h"
#import "Constants.h"

const CGFloat kKeyboardHeight = 305.0f;

static UIColor *sGrayColor = nil;

@interface MRHexKeyboard () {
    __weak UITextField *_textField;
}

- (void)createButtons;
- (void)makeButtonWithRect:(CGRect)rect title:(NSString *)title grayBackground:(BOOL)grayBackground;

- (NSString *)buttonTitleForNumber:(NSInteger)num;
- (CGPoint)buttonOriginPointForNumber:(NSInteger)num;

- (void)changeButtonBackgroundColorForHighlight:(UIButton *)button;
- (void)changeTextFieldText:(UIButton *)button;

@end

@implementation MRHexKeyboard

- (MRHexKeyboard *)initWithTextField:(UITextField *)textField {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kKeyboardHeight)];
    if (self) {
        _textField = textField;
        sGrayColor = [UIColor lightTextColor];
        self.backgroundColor = COLOR_PRIMARY;
        [self createButtons];
    }
    return self;
}

- (void)createButtons {
    CGRect rect = CGRectMake(0.0f, 0.0f, (floor(self.bounds.size.width / 3.0f) + 0.3f), (((kKeyboardHeight - 5.0f) / 6.0f) + 0.3f));
    
    /* Makes numerical buttons */
    for (NSInteger num = 1; num <= 15; num++) {
        rect.origin = [self buttonOriginPointForNumber:num];
        [self makeButtonWithRect:rect title:[self buttonTitleForNumber:num] grayBackground:NO];
    }
    
    /* Makes the '0' button */
    rect.origin = [self buttonOriginPointForNumber:16];
    [self makeButtonWithRect:rect title:@"0" grayBackground:NO];
    
    /* Makes the 'delete' button */
    rect.origin = [self buttonOriginPointForNumber:17];
    UIButton *delButton = [[UIButton alloc] initWithFrame:rect];
    delButton.backgroundColor = [UIColor whiteColor];
    [delButton setImage:[UIImage imageNamed:@"deleteButton"] forState:UIControlStateNormal];
    [delButton addTarget:self action:@selector(changeButtonBackgroundColorForHighlight:) forControlEvents:UIControlEventTouchDown];
    [delButton addTarget:self action:@selector(changeButtonBackgroundColorForHighlight:) forControlEvents:UIControlEventTouchDragEnter];
    [delButton addTarget:self action:@selector(changeButtonBackgroundColorForHighlight:) forControlEvents:UIControlEventTouchDragExit];
    [delButton addTarget:self action:@selector(changeTextFieldText:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delButton];

    /* Makes the no-op button */
    rect.origin = [self buttonOriginPointForNumber:18];
    UIButton *noopButton = [[UIButton alloc] initWithFrame:rect];
    noopButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:noopButton];
}

- (void)makeButtonWithRect:(CGRect)rect title:(NSString *)title grayBackground:(BOOL)grayBackground {
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    CGFloat fontSize = 25.0f;
    button.backgroundColor = (grayBackground) ? sGrayColor : [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeButtonBackgroundColorForHighlight:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(changeButtonBackgroundColorForHighlight:) forControlEvents:UIControlEventTouchDragEnter];
    [button addTarget:self action:@selector(changeButtonBackgroundColorForHighlight:) forControlEvents:UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(changeTextFieldText:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (NSString *)buttonTitleForNumber:(NSInteger)num {
    NSString *str = [NSString stringWithFormat:@"%ld", (long)num];
    if (num <= 15) {
        if (num >= 10) {
            str = @[@"A", @"B", @"C", @"D", @"E", @"F"][num - 10];
        }
    }
    else {
        str = @"F#%K";
    }
    return str;
}

- (CGPoint)buttonOriginPointForNumber:(NSInteger)num {
    CGPoint point = CGPointMake(0.0f, 0.0f);
    if ((num % 3) == 2) { /* 2nd button in the row */
        point.x = ceil(self.bounds.size.width / 3.0f);
    }
    else if ((num % 3) == 0) { /* 3rd button in the row */
        point.x = ceil((self.bounds.size.width / 3.0f * 2.0f));
    }
    if (num > 3) { /* The row multiplied by row's height */
        point.y = floor((num - 1) / 3.0f) * (kKeyboardHeight / 6.0f);
    }
    return point;
}

- (void)changeButtonBackgroundColorForHighlight:(UIButton *)button {
    UIColor *newColor = sGrayColor;
    if ([button.backgroundColor isEqual:sGrayColor]) {
        newColor = [UIColor whiteColor];
    }
    button.backgroundColor = newColor;
}

- (void)changeTextFieldText:(UIButton *)button {
    if (_textField) {
        NSMutableString *string = [NSMutableString stringWithString:_textField.text];
        if (button.titleLabel.text) {
            if (string.length == 0) {
                [string appendFormat:@"0x%@", button.titleLabel.text];
            }
            else {
                if (string.length > 2) {
                    NSString *lastTwoChars = [string substringFromIndex:(string.length - 2)];
                    if ([lastTwoChars rangeOfString:@"x"].location == NSNotFound) {
                        [string appendFormat:@" 0x%@", button.titleLabel.text];
                    }
                    else {
                        [string appendString:button.titleLabel.text];
                    }
                }
                else {
                    [string appendString:button.titleLabel.text];
                }
            }
        }
        else if (_textField.text.length > 0) {
            NSRange deleteRange;
            NSString *lastChar = [string substringFromIndex:(string.length - 1)];
            if ([lastChar isEqualToString:@"x"]) {
                if (string.length > 2) {
                    deleteRange = NSMakeRange((string.length - 3), 3);
                }
                else {
                    deleteRange = NSMakeRange((string.length - 2), 2);
                }
            }
            else {
                deleteRange = NSMakeRange((string.length - 1), 1);
            }
            [string deleteCharactersInRange:deleteRange];
        }
        
        if (_textField.delegate) {
            NSRange range = NSMakeRange(0, _textField.text.length);
            if([_textField.delegate textField:_textField shouldChangeCharactersInRange:range replacementString:string]) {
                _textField.text = string;
            }
        }
        else {
            _textField.text = string;
        }
    }
    
    [self changeButtonBackgroundColorForHighlight:button];
}

-(void) changeViewFrameSizeToFrame:(CGRect)newFrame {
    self.frame = newFrame;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self createButtons];
}

@end
