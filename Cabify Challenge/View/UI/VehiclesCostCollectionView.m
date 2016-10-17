//
//  VehiclesCostCollectionView.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "VehiclesCostCollectionView.h"
#import "VehicleCostViewCell.h"
#import "Constants.h"

#define CABIFYIDENTIFICATORCELL @"CABIFYCELL"

@interface VehiclesCostCollectionView ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end


@implementation VehiclesCostCollectionView
@synthesize vehicles;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"VehiclesCostCollectionView" owner:self options:nil];
        self.collectionView.backgroundColor = CABIFYORANGECOLOR;
        [self addSubview:self.collectionView];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.collectionView registerClass:[VehicleCostViewCell class] forCellWithReuseIdentifier:CABIFYIDENTIFICATORCELL];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

-(void)setVehicles:(NSArray *)vehiclesArray{
    vehicles = vehiclesArray;
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark -
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [vehicles count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    VehicleCabify *item = [vehicles objectAtIndex:indexPath.row];
    
    VehicleCostViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CABIFYIDENTIFICATORCELL forIndexPath:indexPath];
    
    [cell setVehicle:item];
            
    return cell;
}






@end
