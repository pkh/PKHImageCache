//
//  ViewController.m
//  PKHIC-Example
//
//  Created by Patrick Hanlon on 5/8/15.
//  Copyright (c) 2015 pkh. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"
#import "UIImageView+PKHImageCache.h"

#import "PKHImageCache.h"   // for testing clear image cache method


@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *clearCacheButton;
@property (nonatomic, strong) NSArray *shipsArray;

@end

@implementation ViewController
{
    BOOL _cacheShouldClear;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _cacheShouldClear = YES;
    
    self.shipsArray = @[@"http://moviekits.net/wp-content/uploads/2014/04/Star-Wars-B-Wing-Featured-Image.jpg",
                        @"http://www.afewmaneuvers.com/uploads/28de44a9c53ad7377b7691fb3102104b.jpg",
                        @"http://img4.wikia.nocookie.net/__cb20131103181824/starwars/it/images/4/48/Ywing-SWE.jpg",
                        @"http://img.swcombine.com/ships/25/large.jpg",
                        @"http://www.internetmodeler.com/artman/uploads/1/IMG_0556.JPG",
                        @"http://hd.wallpaperswide.com/thumbs/imperial_star_destroyer-t2.jpg",
                        @"http://www.stardestroyer.net/Empire/Tech/Propulsion/isd3.jpg",
                        @"http://img1.wikia.nocookie.net/__cb20060116214832/sw1mush/images/4/49/Ship_capital_vicsd.jpg",
                        @"http://www.rebelsquadrons.org/oob/images/ships/2.jpg",
                        @"http://img2.wikia.nocookie.net/__cb20060129192356/starwars/images/9/9d/Av21landspeeder.jpg",
                        @"http://vignette3.wikia.nocookie.net/battlefront/images/d/df/74-Z.PNG/revision/latest?cb=20111022144527"
                        ];
    
    [self configureClearCacheButton];
    
    [self configureCollectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat xPadding = 20.0;
    
    CGFloat clearButtonYPadding = 10.0;
    CGFloat clearButtonHeight = 44.0;
    
    CGFloat cvYCoord = statusBarHeight + (clearButtonYPadding*2) + clearButtonHeight;
    CGFloat cvHeight = viewHeight - statusBarHeight - (clearButtonYPadding *2) - clearButtonHeight;
    
    self.clearCacheButton.frame = CGRectMake(xPadding, statusBarHeight+clearButtonYPadding, viewWidth-(xPadding*2), clearButtonHeight);
    
    self.collectionView.frame = CGRectMake(0, cvYCoord, viewWidth, cvHeight);
}

#pragma mark - Configure Clear Cache Button

- (void)configureClearCacheButton
{
    self.clearCacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearCacheButton.backgroundColor = [UIColor darkGrayColor];
    [self.clearCacheButton.titleLabel setTextColor:[UIColor whiteColor]];
    [self.clearCacheButton setTitle:@"Reload Collection View" forState:UIControlStateNormal];
    [self.clearCacheButton addTarget:self action:@selector(clearCacheButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearCacheButton];
}

#pragma mark - Collection View

- (UICollectionViewFlowLayout *)defaultCollectionViewLayout
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];

    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;

    layout.itemSize = CGSizeMake(200, 200);
    layout.headerReferenceSize = CGSizeMake(0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    return layout;
}

- (void)configureCollectionView
{
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self defaultCollectionViewLayout]];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ImageCollectionViewCell class])];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - CollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shipsArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)configureCell:(ImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *link = self.shipsArray[indexPath.row];
    NSURL *imageURL;
    
    if (_cacheShouldClear) {
        imageURL = nil;
    } else {
        imageURL = [NSURL URLWithString:link];
    }
    
    [cell.imageView pkhic_setImageWithURL:imageURL andPlaceholderImage:[UIImage imageNamed:@"placeholder"]];
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ImageCollectionViewCell class]) forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Button Action

- (void)clearCacheButtonAction
{
    if (_cacheShouldClear == YES) {
        [self.collectionView reloadData];
        [self.clearCacheButton setTitle:@"Clear Cache" forState:UIControlStateNormal];
    } else {
        [[PKHImageCache sharedImageCache] clearAndEmptyCache];
        [self.collectionView reloadData];
        [self.clearCacheButton setTitle:@"Reload Collection View" forState:UIControlStateNormal];
    }
    _cacheShouldClear = !_cacheShouldClear;
}

@end
