//
//  FilesViewController.m
//  MFiles
//
//  Created by David Paul Quesada on 3/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "FilesViewController.h"
#import "MFileClient.h"
#import "File.h"

@interface FilesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property NSString *path;
@property UITableView *tableView;
@property NSArray *items;
@end

@implementation FilesViewController

-(id)initWithPath:(NSString *)path
{
    self = [self init];
    if (self)
        self.path = path;
    return self;
}

-(void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view = _tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [_path lastPathComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_items)
    {
        MFileClient *client = [MFileClient sharedClient];
        [client getFilesAtPath:_path withCompletionHandler:^(NSArray *filenames) {
            self.items = filenames;
            [self.tableView reloadData];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *file = _items[indexPath.row];
    if (!file.isDirectory)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *file = _items[indexPath.row];
    
    [[MFileClient sharedClient] deleteFileAtPath:file.path withCompletionHandler:^(BOOL success, NSError *error) {
        
        NSLog(@"Finished deleting file: %d, %@", success, error);
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *item = _items[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"2"];
    
    cell.textLabel.text = item.title;
    cell.accessoryType = (item.isDirectory) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    File *item = _items[indexPath.row];
    NSString *path = [_path stringByAppendingPathComponent:item.title];
    FilesViewController *next = [[FilesViewController alloc] initWithPath:path];
    [self.navigationController pushViewController:next animated:YES];
}

@end
