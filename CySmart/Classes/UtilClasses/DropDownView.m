// DropDownView.m
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


#import "DropDownView.h"

@implementation DropDownView

{
    UITapGestureRecognizer *tapGestureRecognizer;
    BOOL firstrowActive;
    UIView *bottomBlueView;
    NSArray *imageArray;
    UIView *shadowView;
}

#pragma mark - initMethods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onButton:(UIButton*)sender
{
    self.parentButton=sender;
    self.dropdownType=basic;
    CGFloat width=(([self getMaxLength:titleArray forFont:sender.titleLabel.font maxHeight:sender.frame.size.height]+10)> sender.frame.size.width) ? [self getMaxLength:titleArray forFont:sender.titleLabel.font maxHeight:sender.frame.size.height]+10:sender.frame.size.width;
    
    CGFloat rowHeight=sender.frame.size.height+4;
    
    //This is not readable so dont waste your time :p
    
    CGFloat height=(rowHeight*titleArray.count>([self getAncestorView:sender].frame.origin.y+[self getAncestorView:sender].frame.size.height-([sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].origin.y+[sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].size.height+10))) ? [self getAncestorView:sender].frame.origin.y+[self getAncestorView:sender].frame.size.height-([sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].origin.y+[sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].size.height+10):rowHeight*titleArray.count;
    
    height=height-((int)height%(int)rowHeight);
    
    if(self=[self initWithFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y+sender.frame.size.height, width, height)])
    {
        self.delegate=delegate;
        self.cellHeight=rowHeight;
        self.hidden=YES;
        _dropDownTableView=[[UITableView alloc]init];
        
        _dropDownTableView.frame=CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
        _dropDownTableView.dataSource=self;
        _dropDownTableView.delegate=self;
        
        _dropDownTableView.layer.cornerRadius=2.0;
        self.layer.cornerRadius=2.0;
        
        _dropDownTableView.layer.borderColor=[UIColor blackColor].CGColor;
        _dropDownTableView.layer.borderWidth=0.5f;
      
        [self addSubview:_dropDownTableView];
        _dropDownList=[[NSArray alloc]initWithArray:titleArray];
        _dropDownTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
   
        self.frame=[sender.superview convertRect:self.frame toView:[self getAncestorView:sender]];
        [[self getAncestorView:sender] addSubview:self];
        tapGestureRecognizer=[[UITapGestureRecognizer alloc]init];
        tapGestureRecognizer.cancelsTouchesInView=NO;
        tapGestureRecognizer.delegate=(id)self;
        [[self getAncestorView:self.parentButton] addGestureRecognizer:tapGestureRecognizer];
    }
    
    return self;
}

-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onButton:(UIButton*)sender withFrame:(CGRect)frame
{
    self.parentButton=sender;
    self.dropdownType=basic;
    CGFloat width= frame.size.width;
    
    CGFloat rowHeight=frame.size.height - 4;
    
    //This is not readable so dont waste your time :p
    
    CGFloat height=(rowHeight*titleArray.count>([self getAncestorView:sender].frame.origin.y+[self getAncestorView:sender].frame.size.height-([sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].origin.y+[sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].size.height+10))) ? [self getAncestorView:sender].frame.origin.y+[self getAncestorView:sender].frame.size.height-([sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].origin.y+[sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].size.height+10):rowHeight*titleArray.count;
    
    height=height-((int)height%(int)rowHeight);
    
    if(self=[self initWithFrame:CGRectMake(frame.origin.x, sender.frame.origin.y+sender.frame.size.height, width, height)])
    {
        self.delegate=delegate;
        self.cellHeight=rowHeight;
        self.hidden=YES;
        _dropDownTableView=[[UITableView alloc]init];
        
        _dropDownTableView.frame=CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
        _dropDownTableView.dataSource=self;
        _dropDownTableView.delegate=self;
        
        _dropDownTableView.layer.cornerRadius=2.0;
        self.layer.cornerRadius=2.0;
        
        _dropDownTableView.layer.borderColor=[UIColor blackColor].CGColor;
        _dropDownTableView.layer.borderWidth=0.5f;
        
        [self addSubview:_dropDownTableView];
        _dropDownList=[[NSArray alloc]initWithArray:titleArray];
        _dropDownTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        
        self.frame=[sender.superview convertRect:self.frame toView:[self getAncestorView:sender]];
        [[self getAncestorView:sender] addSubview:self];
        tapGestureRecognizer=[[UITapGestureRecognizer alloc]init];
        tapGestureRecognizer.cancelsTouchesInView=NO;
        tapGestureRecognizer.delegate=(id)self;
        [[self getAncestorView:self.parentButton] addGestureRecognizer:tapGestureRecognizer];
    }
    
    return self;
}


-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onButton:(UIButton*)sender frame:(CGRect)frame font:(UIFont*) font highLightedRow:(int) row
{
    
    self.highlightedRow=row;
    self.parentButton=sender;
    
    CGFloat width=frame.size.width;
 
    CGFloat rowHeight=frame.size.height;

    CGFloat height=frame.size.height*titleArray.count;
    
    if(self=[self initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, width, height)])
    {
        self.delegate=delegate;
        self.cellHeight=rowHeight;
        self.hidden=YES;
        greyView=[[UIView alloc]initWithFrame:[self getAncestorView:self].bounds];
        [greyView setBackgroundColor:[UIColor blackColor]];
        greyView.alpha=0.6;
        [[self getAncestorView:sender] addSubview:greyView];
        self.textFont=font;
        _dropDownTableView=[[UITableView alloc]init];
        
        _dropDownTableView.frame=CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
        _dropDownTableView.dataSource=self;
        _dropDownTableView.delegate=self;
        firstrowActive=NO;
        _dropDownTableView.scrollEnabled=NO;
        UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dropDownTableView.frame.size.width, self.cellHeight+10)];
        UILabel *headerLabel=[[UILabel alloc]initWithFrame:headerView.bounds];
        headerLabel.textAlignment=NSTextAlignmentCenter;
        [headerView addSubview:headerLabel];
        [headerLabel setText:@"Choose Your Filter"];
        [headerLabel setBackgroundColor:[UIColor lightGrayColor]];
        [headerLabel setFont:font];
        
        _dropDownTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        
        [self addSubview:_dropDownTableView];
        _dropDownList=[[NSArray alloc]initWithArray:titleArray];
        CGRect frames=CGRectMake(self.parentButton.center.x-self.parentButton.frame.size.width/4, self.parentButton.frame.origin.y+self.parentButton.frame.size.height,self.parentButton.frame.size.width/2,frame.origin.y-(self.parentButton.frame.origin.y+self.parentButton.frame.size.height));
        frames.origin.x-=self.frame.origin.x;
        frames.origin.y-=self.frame.origin.y;
        //frames.origin.y+=2;
        NSLog(@"%@",NSStringFromCGRect(frames));
        UIImageView *arrowImage=[[UIImageView alloc]initWithFrame:frames];
        [arrowImage setImage:[UIImage imageNamed:@"drop_down_arrow"]];
       
        [self addSubview:arrowImage];
        self.frame=[sender.superview convertRect:self.frame toView:[self getAncestorView:sender]];
        [[self getAncestorView:sender] addSubview:self];
       
        tapGestureRecognizer=[[UITapGestureRecognizer alloc]init];
        tapGestureRecognizer.cancelsTouchesInView=NO;
        tapGestureRecognizer.delegate=(id)self;
        [[self getAncestorView:self.parentButton] addGestureRecognizer:tapGestureRecognizer];
  
    }
    
    return self;
}

-(id) initWithDelegate:(id) delegate titles:(NSArray*) titleArray onView:(UIView*)sender font:(UIFont*) font highLightedRow:(int) row
{
    
    firstrowActive=YES;
    self.parentButton=sender;
    self.highlightedRow=row;
    CGRect frame=CGRectMake(sender.frame.origin.x, sender.frame.origin.y+sender.frame.size.height, sender.frame.size.width, sender.frame.size.height);
    _isShown=NO;
    
    CGFloat width=frame.size.width;
    
    CGFloat rowHeight=frame.size.height;
    
    CGFloat height=frame.size.height*3;

    if(self=[self initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, width, height)])
    {
        self.delegate=delegate;
        self.cellHeight=rowHeight;
        self.hidden=YES;
        greyView=[[UIView alloc]initWithFrame:[self getAncestorView:self].bounds];
        [greyView setBackgroundColor:[UIColor blackColor]];
        greyView.alpha=0.6;
        self.textFont=font;
        _dropDownTableView=[[UITableView alloc]init];
        
        _dropDownTableView.frame=CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
        _dropDownTableView.dataSource=self;
        _dropDownTableView.delegate=self;
        _dropDownTableView.scrollEnabled=YES;
        _dropDownTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        
        [self addSubview:_dropDownTableView];
        _dropDownList=[[NSArray alloc]initWithArray:titleArray];
        CGRect frames=CGRectMake(self.parentButton.center.x-self.parentButton.frame.size.width/4, self.parentButton.frame.origin.y+self.parentButton.frame.size.height,self.parentButton.frame.size.width/2,frame.origin.y-(self.parentButton.frame.origin.y+self.parentButton.frame.size.height));
        frames.origin.x-=self.frame.origin.x;
        frames.origin.y-=self.frame.origin.y;
        NSLog(@"%@",NSStringFromCGRect(frames));
        
        bottomBlueView=[[UIView alloc]initWithFrame:CGRectMake(0, self.dropDownTableView.frame.origin.y+self.dropDownTableView.frame.size.height, self.dropDownTableView.frame.size.width, 2)];
        [bottomBlueView setBackgroundColor:[UIColor colorWithRed:0.0 green:125.0/255.0 blue:202.0/255.0 alpha:1]];
        [self addSubview:bottomBlueView];
        UIImageView *arrowImage=[[UIImageView alloc]initWithFrame:frames];
        [arrowImage setImage:[UIImage imageNamed:@"drop_down_arrow"]];
        [self addSubview:arrowImage];
        self.frame=[sender.superview convertRect:self.frame toView:[self getAncestorView:sender]];
        [[self getAncestorView:sender] addSubview:self];
        
    }
    
    return self;
}
-(id) initWithDelegate:(id) delegate titles:(NSArray*)titleArray Images:(NSArray*)images onView:(UIView*)sender font:(UIFont*) font fontColor:(UIColor*) fontcolor bgColor:(UIColor*)bgColor
{
    self.dropdownType=coloured;
    self.parentButton=sender;
    self.bgColor=bgColor;
    self.textColour=fontcolor;
    self.textFont=font;
    imageArray=[NSArray arrayWithArray:images];
    CGRect frame=CGRectMake(sender.frame.origin.x, sender.frame.origin.y+sender.frame.size.height, sender.frame.size.width, sender.frame.size.height);
    _isShown=NO;
    
    CGFloat width = 115;
    CGFloat rowHeight=40;
    
    //This is not readable so dont waste your time :p
    CGFloat height=(rowHeight*titleArray.count>([self getAncestorView:sender].frame.origin.y+[self getAncestorView:sender].frame.size.height-([sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].origin.y+[sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].size.height+10))) ? [self getAncestorView:sender].frame.origin.y+[self getAncestorView:sender].frame.size.height-([sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].origin.y+[sender.superview convertRect:sender.frame toView:[self getAncestorView:sender]].size.height+10):rowHeight*titleArray.count;
    
    height=height-((int)height%(int)rowHeight);
    
    
    
    if(self=[self initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, width, height)])
    {
        self.delegate=delegate;
        self.cellHeight=rowHeight;
        self.hidden=YES;
        
        tapGestureRecognizer=[[UITapGestureRecognizer alloc]init];
        tapGestureRecognizer.cancelsTouchesInView=NO;
        tapGestureRecognizer.delegate=(id)self;
        
        [[self getAncestorView:self.parentButton] addGestureRecognizer:tapGestureRecognizer];
        greyView=[[UIView alloc]initWithFrame:[self getAncestorView:self].bounds];
        [greyView setBackgroundColor:[UIColor clearColor]];
        [greyView addGestureRecognizer:tapGestureRecognizer];
        [[self getAncestorView:sender] addSubview:greyView];
        self.textFont=font;
        _dropDownTableView=[[UITableView alloc]init];
        
        _dropDownTableView.frame=CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
        _dropDownTableView.dataSource=self;
        _dropDownTableView.delegate=self;
        _dropDownTableView.scrollEnabled=YES;
                _dropDownTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        [_dropDownTableView setBackgroundColor:bgColor];
        
        [self addSubview:_dropDownTableView];
        _dropDownList=[[NSArray alloc]initWithArray:titleArray];
        CGRect frames=CGRectMake(self.parentButton.center.x-self.parentButton.frame.size.width/4, self.parentButton.frame.origin.y+self.parentButton.frame.size.height,self.parentButton.frame.size.width/2,frame.origin.y-(self.parentButton.frame.origin.y+self.parentButton.frame.size.height));
        frames.origin.x-=self.frame.origin.x;
        frames.origin.y-=self.frame.origin.y;
        NSLog(@"%@",NSStringFromCGRect(frames));
        
        bottomBlueView=[[UIView alloc]initWithFrame:CGRectMake(0, self.dropDownTableView.frame.origin.y+self.dropDownTableView.frame.size.height, self.dropDownTableView.frame.size.width, 2)];
        [bottomBlueView setBackgroundColor:[UIColor colorWithRed:0.0 green:125.0/255.0 blue:202.0/255.0 alpha:1]];
        UIImageView *arrowImage=[[UIImageView alloc]initWithFrame:frames];
        [arrowImage setImage:[UIImage imageNamed:@"drop_down_arrow"]];
        [self addSubview:arrowImage];
        self.frame=[sender.superview convertRect:self.frame toView:[self getAncestorView:sender]];
        [[self getAncestorView:sender] addSubview:self];
        
        
        
        
        
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}
-(void)showView
{
    if(!_isShown)
    {
    _isShown=YES;

    [self checkForFurtherDropDowns:[self getAncestorView:self.parentButton]];
    self.hidden=NO;
    if([self.parentButton isKindOfClass:[UIButton class]])
        [((UIButton*)self.parentButton) setSelected:YES];
    [self disableScroll:YES from:_parentButton];
    CGRect frames=self.frame;
    self.frame=CGRectMake(frames.origin.x, frames.origin.y,frames.size.width,0);
    self.dropDownTableView.frame=self.bounds;
    [self animate:frames.size.height];
    }
    
}


-(void)reloadDataWith:(NSArray*)array
{
    _dropDownList=[[NSArray alloc]initWithArray:array];
    [self.dropDownTableView reloadData];
}

-(void) removeSubviews{
    [[self getAncestorView:self.parentButton] removeGestureRecognizer:tapGestureRecognizer];
    [self removeFromSuperview];
    [greyView removeFromSuperview];

}

-(void)hideView
{
    _isShown=NO;
    [self disableScroll:NO from:_parentButton];
    __weak __typeof(self) wself = self;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        __strong __typeof(self) sself = wself;
        if (sself) {
            sself.frame=CGRectMake(sself.frame.origin.x, sself.frame.origin.y, sself.frame.size.width, 0);
            sself.dropDownTableView.frame=sself.bounds;
        }
    }
                     completion:^(BOOL finished) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if([sself.parentButton isKindOfClass:[UIButton class]])
                [((UIButton*)sself.parentButton) setSelected:NO];
            
            [[sself getAncestorView:sself.parentButton] removeGestureRecognizer:sself->tapGestureRecognizer];
            [sself removeFromSuperview];
            [sself->greyView removeFromSuperview];
        }
    }];
}

-(void)animate:(CGFloat)height
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width,height);
         self.dropDownTableView.frame=self.bounds;
     }
                     completion:nil];
    
}

-(void)animateWithBlue:(CGFloat)height
{
    __weak __typeof(self) wself = self;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        __strong __typeof(self) sself = wself;
        if (sself) {
            sself.frame=CGRectMake(sself.frame.origin.x, sself.frame.origin.y, sself.frame.size.width, height);
            sself.dropDownTableView.frame=sself.bounds;
            sself->bottomBlueView.frame=CGRectMake(0, sself.dropDownTableView.frame.origin.y + sself.dropDownTableView.frame.size.height, sself.dropDownTableView.frame.size.width, 2);
        }
    } completion:nil];
}

-(void)showView:(UIView*)view action:(BOOL)action
{
    view.alpha=(float)(!action);
    [UIView beginAnimations:@"showOrHideView" context:nil];
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         view.alpha=(float)action;
     }completion:^(BOOL finished)
     {
         if(!action)
             [view removeFromSuperview];
     }
     ];
}
-(void)showViewWithBlueBorder
{
    
    if(!_isShown)
    {
        _isShown=YES;
        
        [self checkForFurtherDropDowns:[self getAncestorView:self.parentButton]];
        self.hidden=NO;
        if([self.parentButton isKindOfClass:[UIButton class]])
            [((UIButton*)self.parentButton) setSelected:YES];
        [self disableScroll:YES from:_parentButton];
        CGRect frames=self.frame;
        self.frame=CGRectMake(frames.origin.x, frames.origin.y,frames.size.width,2);
        bottomBlueView.frame=CGRectMake(0, 0, bottomBlueView.frame.size.width, bottomBlueView.frame.size.height);
        self.dropDownTableView.frame=CGRectMake(0, 0,self.dropDownTableView.frame.size.width, 0);
        [self animateWithBlue:frames.size.height];
    }

    
}
-(void)hideViewWithBlueBorder
{
    
}
#pragma mark - TableView Delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (_dropdownType)
    {
        case ordinary:
        {
            cell.textLabel.textAlignment=NSTextAlignmentLeft;
            cell.textLabel.font=self.textFont;
            if(!firstrowActive)
            {
                if(indexPath.row==0)
                {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    
                }
                if(self.highlightedRow==indexPath.row||!indexPath.row)
                {
                    cell.textLabel.textColor=[UIColor blackColor];
                    
                }
                else
                {
                    cell.textLabel.textColor=[UIColor grayColor];
                }
            }
            else
            {
                cell.textLabel.textColor=[UIColor blackColor];
                
            }
            
            cell.textLabel.text=[self.dropDownList objectAtIndex:indexPath.row];
        }
        break;
        
        case coloured:
        {
            cell.textLabel.textAlignment=NSTextAlignmentLeft;
            cell.textLabel.font=self.textFont;
            cell.textLabel.textColor=self.textColour;
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 0, 35/1.75, 50/1.75)];
            [cell.contentView addSubview:imageView];
            if([imageArray objectAtIndex:indexPath.row])
            {
                UIImage *image=[UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
                imageView.image=image;
            }
            imageView.center=CGPointMake(imageView.center.x, cell.center.y);
            cell.textLabel.text=[self.dropDownList objectAtIndex:indexPath.row];
            cell.textLabel.hidden=YES;
            UILabel *titleLabel1=[[UILabel alloc] initWithFrame:CGRectMake(35, 0, 85, 50)];
            [cell .contentView addSubview:titleLabel1];
            titleLabel1.textAlignment=NSTextAlignmentLeft;
            titleLabel1.font=self.textFont;
            titleLabel1.textColor=self.textColour;
            titleLabel1.text=[self.dropDownList objectAtIndex:indexPath.row];
        }
            break;
        case basic:
        {
            cell.textLabel.textAlignment=NSTextAlignmentLeft;
            cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
            cell.textLabel.textColor=[UIColor blackColor];
            cell.textLabel.text=[self.dropDownList objectAtIndex:indexPath.row];
        }

            break;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dropDownList.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dropdownType==coloured)
    {
        if([self.delegate respondsToSelector:@selector(dropDown:valueSelected:index:)])
        {
            [self.delegate dropDown:self valueSelected:[self.dropDownList objectAtIndex:indexPath.row] index:(int)indexPath.row];
        }
        [self hideView];
    }
    else if(self.dropdownType ==ordinary)
    {
        if(!indexPath.row&&!firstrowActive)
            [self hideView];
        
        else  if([self.delegate respondsToSelector:@selector(dropDown:valueSelected:index:)])
        {
            [self.delegate dropDown:self valueSelected:[self.dropDownList objectAtIndex:indexPath.row] index:(int)indexPath.row];
        }
        [self hideView];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(dropDown:valueSelected:index:)])
        {
            [self.delegate dropDown:self valueSelected:[self.dropDownList objectAtIndex:indexPath.row] index:(int)indexPath.row];
        }
        [self hideView];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor=_bgColor;
}

#pragma mark - Utility Methods

-(CGFloat)getMaxLength:(NSArray*)array forFont:(UIFont*) font maxHeight:(CGFloat) maxHeight
{
    CGFloat max=0.0;
    
    for(NSString *string in array)
    {
      
        if([string boundingRectWithSize:CGSizeMake(1000,font.pointSize) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil] context:nil].size.width>max)
            max=[string boundingRectWithSize:CGSizeMake(1000,font.pointSize) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil] context:nil].size.width;
        
    }
    return max;
}

-(UIView*)getAncestorView:(UIView*)view
{
    return [[[UIApplication sharedApplication] delegate] window];
}
-(void)checkForFurtherDropDowns:(UIView*)view
{
    for(UIView *views in view.subviews)
    {
        if([views isKindOfClass:[DropDownView class]]&&views!=self)
           [((DropDownView*)views) hideView];
        else
        {
            if(views.subviews)
                [self checkForFurtherDropDowns:views];
        }
    }
}

-(NSString*)getNameFromImageName:(NSString*)string
{
    return [[string substringToIndex:[string rangeOfString:@"_"].location] uppercaseString];
}

-(UIView*)disableScroll:(BOOL)boolVal from:(UIView*)view
{
    while (view.superview)
    {
       
        if([view isKindOfClass:[UIScrollView class]])
        {
            [((UIScrollView*)view) setScrollEnabled:!boolVal];
        }
        view=view.superview;
    }
    return view;
}

#pragma mark - Gesture delegates

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:self];
    if(!CGRectContainsPoint(self.bounds,touchLocation)||CGRectContainsPoint(self.parentButton.bounds,[touch locationInView:self.parentButton]))
       [self hideView];
    return NO;
}
@end
