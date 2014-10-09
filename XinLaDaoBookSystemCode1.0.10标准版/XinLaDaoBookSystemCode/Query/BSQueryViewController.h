//
//  BSQueryViewController.h
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDataProvider.h"
#import "BSChuckView.h"
#import "BSQueryCell.h"
#import "BSQueryCell.h"

#import "AKMySegmentAndView.h"

@interface BSQueryViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,ChuckViewDelegate,UISearchBarDelegate,BSQueryCellDelegate,UITextFieldDelegate,AKMySegmentAndViewDelegate>{
    BSChuckView *vChuck;
    UITableView *tvOrder;
    
}

@end
