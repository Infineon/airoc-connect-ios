//
//  DrawingHelpers.h
//  
//
//  Created by Marcel Ruegenberg on 21.09.09.

//+Copyright (C) 2012 Marcel Ruegenberg
//+
//+Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//+
//+The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//+
//+THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import <UIKit/UIKit.h>

void CGPathAddRoundedRectSimple(CGMutablePathRef path, CGRect rect, CGFloat radius);

/**
 Add a rounded rectangle to the current CGContext.
 @param c the CGContext
 @param rect the rectangle to which the rounded rectangle corresponds
 @param radius the radius of the arcs of the rectangle corners
 */
void CGContextAddRoundedRect(CGContextRef c, CGRect rect, CGFloat radius);

/**
 Stroke a rounded rectangle in a CGContext.
 */
void CGContextStrokeRoundedRect(CGContextRef c, CGRect rect, CGFloat radius);

/**
 Fill a rounded rectangle in a CGContext.
 */
void CGContextFillRoundedRect(CGContextRef c, CGRect rect, CGFloat radius);

/**
 Clip a CGContext to a rounded rectangle.
 */
void CGContextClipToRoundedRect(CGContextRef c, CGRect rect, CGFloat radius);


/**
 Draw a linear gradient with a number of colors.
 This function is very similar to CGGradientCreateWithColors, but immediately draws the gradient and keeps us from having to worry about color spaces.
 
 Please note that the supplied UIColors in the array must be RGB colors.
 */
void DL_CGContextDrawLinearGradient(CGContextRef context, NSArray *colors, const CGFloat locations[], CGPoint startPoint, CGPoint endPoint);

/**
 Draw a linear gradient from top to bottom of a supplied rectangle.
 */
void DL_CGContextDrawLinearGradientOverRect(CGContextRef context, NSArray *colors, const CGFloat locations[], CGRect rect);

/**
 Draw the typical steel gradient.
 */
void DL_CGContextDrawSteelGradientOverRect(CGContextRef context, CGRect rect);
void DL_CGContextDrawLightSteelGradientOverRect(CGContextRef context, CGRect rect);

/**
 Draw highlights at top and bottom.
 */
void DL_CGContextDrawHighlightsOverRect(CGContextRef context, CGRect rect);

#define DISCLOSURE_IND_SIZE 6
/**
 Draw a disclosure indicator
 @param upLeft The upper left corner of the disclosure indicator.
 */
void DL_CGContextDrawDisclosureIndicatorAtPoint(CGContextRef context, CGPoint upLeft);

