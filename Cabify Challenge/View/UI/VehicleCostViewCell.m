//
//  VehicleCostView.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "VehicleCostViewCell.h"
#import "APICabify.h"
#import "DBImageView.h"
#import "Constants.h"

@interface VehicleCostViewCell ()

@property (strong, nonatomic) DBImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@end


@implementation VehicleCostViewCell


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"VehicleCostViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        self.iconImageView = [[DBImageView alloc] initWithFrame:CGRectMake(10, 5, 35, 35)];
        self.iconImageView.backgroundColor = [UIColor clearColor];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.iconImageView];
        self.contentView.backgroundColor = CABIFYORANGECOLOR;
        
    }
    
    return self;
    
}

-(void)setVehicle:(VehicleCabify *)vehicle{
    _vehicle = vehicle;
    self.nameLabel.text = vehicle.name;
    self.priceLabel.text = vehicle.price;
    if (vehicle.icon != nil)
        [self.iconImageView setImageWithPath:[vehicle.icon absoluteString]];
}

-(void) setSelected:(BOOL)selected{
    self.contentView.backgroundColor = selected?[UIColor whiteColor] : CABIFYORANGECOLOR;
    [super setSelected:selected];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
