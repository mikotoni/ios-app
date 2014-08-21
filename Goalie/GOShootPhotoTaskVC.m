//
//  GOShootPhotoVC.m
//  Goalie
//
//  Created by Stefan Kroon on 28-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOShootPhotoTaskVC.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOShootPhotoTask.h"

// Services
#import "GOMainApp.h"

// Frameworks
#import <MobileCoreServices/UTCoreTypes.h>

// Misc
#import "CastFunctions.h"

@interface GOShootPhotoTaskVC ()

@end

@implementation GOShootPhotoTaskVC {
    NSDictionary *_imageInfo;
}

//@synthesize task;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (IBAction)cancel:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.editMode) {
        [takePhotoButton setEnabled:NO];
        [photoPreviewView setHidden:NO];
        [noCameraAvailableLabel setHidden:YES];
        [kindOfPhotoTextField setHidden:NO];
        [kindOfPhotoLabel setHidden:YES];
    }
    else {
        [kindOfPhotoTextField setHidden:YES];
        [kindOfPhotoLabel setHidden:YES];
        GOTaskBrew *brew = self.brew;
        GOShootPhotoTask *shootPhotoTask = [brew getTaskWithClass:[GOShootPhotoTask class]];
        [kindOfPhotoLabel setText:[shootPhotoTask name]];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [noCameraAvailableLabel setHidden:YES];
            [photoPreviewView setHidden:NO];
            [takePhotoButton setEnabled:YES];
        }
        else {
            [noCameraAvailableLabel setHidden:NO];
            [photoPreviewView setHidden:YES];
            [takePhotoButton setEnabled:NO];
        }
        if([brew valueForKey:@"photoData"]) {
            UIImage *image = [UIImage imageWithData:[brew valueForKey:@"photoData"]];
            [photoPreviewView setImage:image];
        }
    }
}

#ifdef USE_COREDATA
- (void)saveNewTask {
    NSManagedObjectContext *moc = [self managedObjectContext];
    GOShootPhotoTask *newTask = [GOShootPhotoTask shootPhotoTaskInManagedObjectContext:moc];
    [newTask setName:[NSString stringWithFormat:@"Foto %@", [kindOfPhotoTextField text]]];
    [self addNewTask:newTask];
}
#endif

- (void)completeTask {
    GOTaskBrew *brew = self.brew;
    GOActiveShootPhotoTask *activePhotoTask = $castIf(GOActiveShootPhotoTask, [brew activeTask]);
    [activePhotoTask updateBrew:brew image:acquiredPhoto metadata:[_imageInfo objectForKey:UIImagePickerControllerMediaMetadata]];
    
    [brew save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhotoButtonPressed:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    //[imagePicker setMediaTypes:@[]];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if(CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        acquiredPhoto = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        [photoPreviewView setImage:acquiredPhoto];
        _imageInfo = info;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
