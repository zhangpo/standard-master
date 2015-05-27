//
//  BSTableButtion.h
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    BSTableTypeEmpty=1,        //green空
    BSTableTypeOpen=2,         //yellow开台
    BSTableTypeOrdered=3,      //red点餐
    BSTableTypeCheck=4,        //purple结账
    BSTableTypeSeal=6,         //blue封台
    BSTableTypeChange=7,        //pink换台
    BSTableTypeChildren=8,      //子台位
    BSTableTypeStay=9,          //black挂单
    BSTableTypeNeat=10,          //gray菜齐
}BSTableType;

@class BSTableButton;

@protocol BSTableButtonDelegate

-(void)buildTable:(NSDictionary *)info;

@end

@interface BSTableButton : UIButton {
    BSTableType   tableType;
    
    NSString *tableTitle;
    
    __weak id<BSTableButtonDelegate>_delegate;
    
    BOOL isMoving;
    CGPoint ptStart;
    UILabel *_manTitle;
    UIImageView *imgvCopy;
}


@property (nonatomic,assign) BSTableType tableType;
@property (nonatomic,strong) NSString *tableTitle;
@property(nonatomic,strong)NSDictionary *tableDic;
@property(nonatomic,strong)UILabel *manTitle;
@property (nonatomic,weak)__weak id<BSTableButtonDelegate> delegate;
@end
