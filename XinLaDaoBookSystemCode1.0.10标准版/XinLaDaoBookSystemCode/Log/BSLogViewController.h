//
//  BSLogViewController.h
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDataProvider.h"
#import "BSCommonView.h"
#import "BSLogCell.h"
#import "AKMySegmentAndView.h"
//#import "AKsAuthorizationView.h"
#import "AKsNetAccessClass.h"
#import "BSChuckView.h"
#import "BSAddtionView.h"


@interface BSLogViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,BSLogCellDelegate,CommonViewDelegate,UISearchBarDelegate,UIActionSheetDelegate,AKMySegmentAndViewDelegate,AKsNetAccessClassDelegate,ChuckViewDelegate>{
    UITableView *tvOrder;
    UILabel *lblTitle;
    BSCommonView *vCommon;
    UILabel *lblCommon;
}
- (void)dismissViews;
@end
