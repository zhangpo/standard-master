//
//  BSTableButtion.m
//  BookSystem
//
//  Createdby Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSTableButton.h"


@implementation BSTableButton
@synthesize delegate=_delegate,manTitle=_manTitle,tableDic=_tableDic;


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _manTitle=[[UILabel alloc] initWithFrame:CGRectMake(102,1.5, 30, 20)];
        //        _manTitle.backgroundColor=[UIColor blackColor];
        _manTitle.textAlignment=UITextAlignmentRight;
        
        _manTitle.textColor=[UIColor whiteColor];
        _manTitle.backgroundColor=[UIColor clearColor];
        _manTitle.font=[UIFont systemFontOfSize:14];
        [self addSubview:_manTitle];
        self.titleLabel.font=[UIFont systemFontOfSize:30];
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableviewCellLongPressed:)];
        //将长按手势添加到需要实现长按操作的视图里
        [self addGestureRecognizer:longPress];
    }
    return self;
}
//长按事件
- (void)handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state==UIGestureRecognizerStateEnded) {
        [_delegate buildTable:self.tableDic];
    }
}




- (BSTableType)tableType{
    return tableType;
}

- (void)setTableType:(BSTableType)tableType_{
    if (tableType_!=tableType || (tableType==tableType_ && tableType==BSTableTypeOrdered)){
        tableType = tableType_;
        NSString *strImage;
        switch (tableType) {
            case BSTableTypeEmpty:
                strImage = @"Empty";
                break;
            case BSTableTypeOpen:
                strImage = @"Open";
                break;
            case BSTableTypeOrdered:
                strImage = @"Ordered";
                break;
            case BSTableTypeCheck:
                strImage = @"Check";
                break;
            case BSTableTypeSeal:
                strImage = @"Seal";
                break;
            case BSTableTypeChange:
                strImage = @"Change";
                break;
            case BSTableTypeChildren:
                strImage = @"";
                break;
            case BSTableTypeStay:
                strImage = @"Stay";
                break;
            case BSTableTypeNeat:
                strImage = @"Neat";
                break;
            default:
                break;
        }
        strImage = [NSString stringWithFormat:@"TableButton%@.png",strImage];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:strImage ofType:nil]];
        [self setBackgroundImage:img forState:UIControlStateNormal];
        //        [self setBackgroundColor:color];
        
    }
}


- (NSString *)tableTitle{
    return tableTitle;
}

- (void)setTableTitle:(NSString *)tableTitle_{
    if (tableTitle_!=tableTitle){
        tableTitle = [tableTitle_ copy];
        self.titleLabel.numberOfLines=2;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self setTitle:tableTitle forState:UIControlStateNormal];
    }
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//    isMoving = NO;
//    ptStart = [[touches anyObject] locationInView:self];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//
//    UITouch *touch = [touches anyObject];
//    CGPoint pt = [touch locationInView:self];
//    NSLog(@"Move    x:%f,y:%f",pt.x,pt.y);
//    if (abs(pt.x-ptStart.x)>2 && abs(pt.y-ptStart.y)>2)
//        isMoving = YES;
//    if (isMoving){
//        [self.superview bringSubviewToFront:self];
//        if (!imgvCopy){
//            imgvCopy = [[UIImageView alloc] initWithFrame:self.bounds];
//            [imgvCopy setImage:[self backgroundImageForState:UIControlStateNormal]];
//            UILabel *lbl = [[UILabel alloc] initWithFrame:self.bounds];
//            lbl.backgroundColor = [UIColor clearColor];
//            lbl.textAlignment = UITextAlignmentCenter;
//            lbl.textColor = [UIColor whiteColor];
//            lbl.text = self.currentTitle;
//            [imgvCopy addSubview:lbl];
//            [lbl release];
//            [self addSubview:imgvCopy];
//            [imgvCopy release];
//
//            [self sendSubviewToBack:imgvCopy];
//            imgvCopy.alpha = 0.7f;
//        }
//
//        imgvCopy.center = pt;
//    }
//
//
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    CGPoint pt;
//    pt = [self convertPoint:imgvCopy.center toView:self.superview];
//    CGPoint pt2 = [[touches anyObject] locationInView:self];
//    UIButton *btn = self;
//    NSLog(@"table x:%f,y:%f w:%f,h:%f",btn.frame.origin.x,btn.frame.origin.y,btn.frame.size.width,btn.frame.size.height);
//    if (abs(pt2.x-ptStart.x)<=2 && abs(pt2.y-ptStart.y)<=2)
//        [super touchesEnded:touches withEvent:event];
//    else{
//        int index = [delegate indexOfButtonCoveredPoint:pt];
//        NSLog(@"%d",index);
//        NSLog(@"%d",btn.tag);
//        if (index!=self.tag && -1!=index){
//            [imgvCopy removeFromSuperview];
//            imgvCopy = nil;
//            [delegate replaceOldTable:self.tag withNewTable:index];
//        }
//        else{
//            [UIView animateWithDuration:0.5f animations:^(void) {
//                imgvCopy.center = CGPointMake(self.frame.size.width/2.0f,self.frame.size.height/2.0f);
//            }completion:^(BOOL finished) {
//                if (finished){
//                    [imgvCopy removeFromSuperview];
//                    imgvCopy = nil;
//                }
//            }];
//        }
//
//
//    }
//
//    self.highlighted = NO;
//}
//

@end
