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
@property (nonatomic, strong) NSArray *itemsArray;

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
    
    self.itemsArray = @[@"http://is1.mzstatic.com/image/pf/us/r30/Purple1/v4/08/a1/f0/08a1f0bf-c381-a6b8-8848-ccb0e7931adf/AppIcon60x60_U00402x.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple7/v4/dd/fc/36/ddfc3641-66ec-f271-8efe-d3f84fdc2522/AppIcon60x60_U00402x.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple3/v4/94/00/5a/94005a5d-6b60-bffb-85eb-578e814a22fc/AppIcon60x60_2x.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple7/v4/6f/bd/e0/6fbde007-602d-372c-ed6c-1a8066464450/AppIcon57x57.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple3/v4/f3/c6/d7/f3c6d70c-ef3c-f801-d32a-1572cd798155/AppIcon60x60_U00402x.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple5/v4/b6/70/57/b6705777-e160-2d4b-4921-d214f1549aae/AppIcon60x60_U00402x.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple1/v4/39/6a/1e/396a1e08-6f0c-d07f-c36d-ffcc8fe5f107/AppIcon60x60_U00402x.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple3/v4/0f/71/80/0f71806f-209b-5b70-a71d-84edc521811c/AppIcon60x60_U00402x.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple5/v4/56/ec/8c/56ec8c3c-8a16-8653-fb0a-5514e05596d6/Icon.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple1/v4/f2/8b/62/f28b6276-c842-eef8-42b5-79ebfafe1f8c/AppIcon60x60_U00402x.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple1/v4/21/a5/df/21a5df32-176b-0620-bffa-5b26882b4e6d/AppIcon57x57.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple4/v4/d2/d4/da/d2d4dafd-f453-024f-6d7c-58383f61c134/AppIcon60x60_2x.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple7/v4/e6/56/fe/e656fed8-ccc9-1820-0d68-a61a6fb9192d/Icon.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple4/v4/88/71/69/88716955-e8b3-9737-0970-e1cfd17778c1/AppIcon60x60_2x.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple3/v4/df/3c/77/df3c7711-89b5-c9ba-2d92-84ffec61dc8f/Icon.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple3/v4/49/ee/34/49ee342a-cd57-3cf4-276d-43c2a3c58d20/AppIcon60x60_U00402x.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple3/v4/97/d1/08/97d108b0-9feb-35e0-2b2e-b7bf4778e037/Icon.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple7/v4/18/de/3a/18de3a69-be58-31f7-3a3e-d861d21c9d3b/AppIcon60x60_U00402x.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple7/v4/35/34/44/35344496-24da-706e-c13e-016646942150/Icon.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple1/v4/54/a2/c1/54a2c193-a8f5-b441-3f17-f1d0ea390425/Icon.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple2/v4/4b/d6/3d/4bd63d5f-7cd4-2e30-cab0-25b43a4d155e/Icon.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple5/v4/18/49/6c/18496c35-ed51-daf1-7d9a-6a34ade4abc8/Icon.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple5/v4/59/b0/3e/59b03e4d-19e6-538b-535f-6f86d8f0c626/AppIcon60x60_U00402x.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple3/v4/30/a8/2a/30a82a9e-c21f-44b6-491f-cf1db2a02d2c/Icon.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple/ac/3c/e0/mzi.ogpjlonk.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple3/v4/9d/82/1b/9d821bea-3a77-9d3e-3fc7-efc9e2580458/AppIcon57x57.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple/v4/59/33/4b/59334bf9-cdf9-e8d9-e589-86ef823f9dae/Icon.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple5/v4/3a/88/e0/3a88e05f-03bc-0522-74da-8b8b701ebae7/AppIcon60x60_U00402x.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple1/v4/0a/dc/6e/0adc6ec8-9c52-3b84-110b-a2e1a81d5202/AppIcon60x60_U00402x.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple/v4/62/dc/3f/62dc3fb6-3966-85a0-29a4-9669a41bd3b9/Icon.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple7/v4/9b/38/23/9b382346-13a6-847e-9e4b-9e36c3711ca6/AppIcon60x60_U00402x.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple7/v4/d2/0c/cb/d20ccbde-f098-9b8c-e9a5-51b990e915de/AppIcon57x57.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple4/v4/c4/9c/f3/c49cf397-fd6f-a14a-604f-893f6e7e02dc/AppIcon_MobilePioneers60x60_2x.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple4/v4/64/2e/60/642e604f-3d2b-3f6c-e4c4-94c78cb45402/Icon.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple/v4/f8/90/31/f8903169-8b60-8584-9c33-dd56a318a215/AppIcon57x57.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple3/v4/47/d7/ea/47d7eae1-6574-9a8a-e600-4569f2e638cb/AppIcon57x57.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple1/v4/d7/d6/cf/d7d6cff0-7645-b485-0fb7-aa373cce8240/AppIcon60x60_U00402x.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple5/v4/1c/fd/c5/1cfdc5d8-fedb-6355-baa9-4ba038044e62/Icon57.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple/v4/a5/12/5c/a5125c6a-1b6e-654b-0887-bc988bb93cbd/icon.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple5/v4/cc/82/46/cc8246d4-e810-34db-10dc-6435e5a2f64c/AppIcon57x57.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple/v4/90/18/da/9018da22-2dfe-65ef-4452-81f99dd7f4a2/Icon.png",
                        @"http://is1.mzstatic.com/image/pf/us/r30/Purple3/v4/37/42/5a/37425af5-f159-3272-ed7b-78dd1a9762fb/Icon-57.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple/e5/6a/c6/mzi.odihflrf.png",
                        @"http://is5.mzstatic.com/image/pf/us/r30/Purple7/v4/e5/68/6a/e5686ad7-6599-114a-036e-dc461a305acb/AppIcon60x60_U00402x.png",
                        @"http://is2.mzstatic.com/image/pf/us/r30/Purple/4f/c1/e0/mzi.geyhmqoe.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple/ec/5b/ec/mzi.phvobmns.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple5/v4/65/0a/1a/650a1a21-fa8c-a603-6b93-0aa85fc8a901/AppIcon60x60_U00402x.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple6/v4/89/6f/9c/896f9cf0-cae4-ea5a-5e51-a5cbbe6db0fd/AppIcon60x60_U00402x.png",
                        @"http://is4.mzstatic.com/image/pf/us/r30/Purple7/v4/5c/74/63/5c746359-2e59-98af-bc96-65809d4a4ffd/Icon.png",
                        @"http://is3.mzstatic.com/image/pf/us/r30/Purple2/v4/f0/d3/fd/f0d3fd76-eaae-a34b-3693-05089f2464a2/icon57.png"
                        ];
    
    
    
    [self configureClearCacheButton];
    
    [self configureCollectionView];
    
    NSString *byteCount = [NSByteCountFormatter stringFromByteCount:[[PKHImageCache sharedImageCache] cacheSize] countStyle:NSByteCountFormatterCountStyleFile];
    NSString *message = [NSString stringWithFormat:@"Your local cache is currently %@ in size",byteCount];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cache Size"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
    return self.itemsArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)configureCell:(ImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *link = self.itemsArray[indexPath.row];
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
