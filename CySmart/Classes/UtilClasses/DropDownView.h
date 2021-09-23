// DropDownView.h
//
// Created by Akhil Subrahmanian

//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class DropDownView;

typedef enum DropDownType
{
    ordinary=0,coloured=1,basic=2
}DropDownType;

@protocol DropDownDelegate <NSObject>

-(void)dropDown:(DropDownView*)dropDown valueSelected:(NSString*)value index:(int) index;

@end

@interface DropDownView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UIView *greyView;
}
@property(strong,nonatomic) UITableView *dropDownTableView;
@property (strong )id <DropDownDelegate> delegate;

@property (strong) UIFont *textFont;
@property (strong) UIColor *textColour;
@property (strong) UIColor *bgColor;
@property(strong,nonatomic) NSArray *dropDownList;
@property(nonatomic) CGFloat cellHeight;
@property (retain,nonatomic)UIView *parentButton;

@property int highlightedRow;
@property BOOL isShown;
@property DropDownType dropdownType;
@property (weak, nonatomic) IBOutlet UILabel *dropDownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownImage;

-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onButton:(UIButton*)sender;
-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onButton:(UIButton*)sender withFrame:(CGRect)frame;

-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onButton:(UIButton*)sender frame:(CGRect)frame font:(UIFont*) font highLightedRow:(int) row;

-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onView:(UIView*)sender font:(UIFont*) font highLightedRow:(int) row;
-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray Images:(NSArray*)images onView:(UIView*)sender font:(UIFont*) font fontColor:(UIColor*) fontcolor bgColor:(UIColor*)bgColor;

-(void)showView;
-(void)hideView;
-(void)showViewWithBlueBorder;

-(void)reloadDataWith:(NSArray*)array;
-(void)removeSubviews;


@end
