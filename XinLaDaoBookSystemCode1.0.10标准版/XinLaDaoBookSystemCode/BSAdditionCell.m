//
//  BSAdditionCell.m
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSAdditionCell.h"
#import "CVLocalizationSetting.h"


@implementation BSAdditionCell
@synthesize info;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        bSelected = NO;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"Unselected.png"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
        btn.userInteractionEnabled = NO;
        
        [self.contentView addSubview:btn];
        
        lblContent = [[UILabel alloc] init];
        lblContent.backgroundColor = [UIColor clearColor];
        lblContent.font = [UIFont boldSystemFontOfSize:22];
        
        lblPrice = [[UILabel alloc] init];
        lblPrice.textAlignment = UITextAlignmentRight;
        lblPrice.backgroundColor = [UIColor clearColor];
        lblPrice.font = [UIFont boldSystemFontOfSize:22];
        
        [self addSubview:lblContent];
        [self addSubview:lblPrice];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)clicked{
    bSelected = !bSelected;
    [btn setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:bSelected?@"Selected.png":@"Unselected.png"] forState:UIControlStateNormal];
    
    
}

- (BOOL)bSelected{
    return bSelected;
}

- (void)setBSelected:(BOOL)bSelected_{
    bSelected = bSelected_;
    
    [btn setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:bSelected?@"Selected.png":@"Unselected.png"] forState:UIControlStateNormal];
}

- (void)setHeight:(float)height{
    btn.center = CGPointMake(5+btn.frame.size.width/2.0f, height/2.0f);
    lblContent.frame = CGRectMake(5+btn.frame.size.width*1.5f, 0, 180, height);
    lblPrice.frame = CGRectMake(lblContent.frame.origin.x+180, 0, 70, height);
}

- (void)setContent:(NSDictionary *)dict withTag:(int)tag{
    if (tag==1) {
        self.info = dict;
        lblContent.text = [dict objectForKey:@"FoodFuJia_Des"];
        lblPrice.text=[dict objectForKey:@"FoodFujia_Checked"];
    }
    else
    {
        self.info = dict;
        lblContent.text = [dict objectForKey:@"DES"];
    }
    
//    lblPrice.text = [NSString stringWithFormat:@"%.2f",[[dict objectForKey:@"FoodFujia_Checked"] floatValue]];
}
@end
