//
//  MapClusteringPrototypeiPhoneViewController.m
//  MapClusteringPrototypeiPhone
//
//  Created by Vlado Grancaric on 1/07/10.
//  Copyright VLADZZ
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MapClusteringPrototypeiPhoneViewController.h"

#import "AssetController.h"

@implementation MapClusteringPrototypeiPhoneViewController

@synthesize localMapView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
  queue = [[NSOperationQueue alloc] init];   
  
  CLLocationCoordinate2D centerPoint;
  centerPoint.latitude = -37.814836;
  centerPoint.longitude = 144.957025;
  
  MKCoordinateSpan span;
  span.latitudeDelta = 0.007798;
  span.longitudeDelta = 0.006866;
  
  MKCoordinateRegion region = MKCoordinateRegionMake(centerPoint, span);
  
  [localMapView setRegion:region];
  [localMapView regionThatFits:region];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [queue release];
  [localMapView release];
  [super dealloc];
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {  
  NSArray *annotations = [mapView annotations];
  
  [mapView removeAnnotations:annotations];
  
  MKCoordinateRegion currentRegion = mapView.region;
  
  NSValue *regionAsValue = [NSValue valueWithBytes:&currentRegion objCType:@encode(MKCoordinateRegion)];    
  
  NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                          selector:@selector(updateAssetsOnRegion:)
                                                                            object:regionAsValue];
  if(operation != nil) {
    //Cancel any previous operations before we proceed with this one
    [queue cancelAllOperations];
    
    [queue addOperation:operation];  
  }
  
  [operation release];
  
}

- (void) updateAssetsOnRegion: (NSValue*) value{
  
  NSMutableArray *assetItems = [AssetController getAssetsByCoordinateRegion:value];
  
  if(!clusterer) {
    clusterer = [[AnnotationClusterer alloc] initWithMapAndAnnotations:localMapView];  
  } else {
    [clusterer removeAnnotations];
  }
  
  [clusterer addAnnotations:assetItems];
    
  [localMapView addAnnotations:clusterer.clusters];  
   
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
  static NSString *identifier = @"currentloc";
  
  if([annotation isKindOfClass:[AssetClusterAnnotation class]]) {
    AssetClusterAnnotation *canno = annotation;
    
    MKPinAnnotationView *annView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if(annView == nil) {
      annView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"] autorelease];
      annView.canShowCallout = YES;
      
      if([canno totalMarkers] > 1) {
        annView.pinColor = MKPinAnnotationColorPurple;
      } else {
        annView.pinColor = MKPinAnnotationColorRed;
      }      
      
      UIButton *addButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];      
      [addButton setTag:1];
      annView.rightCalloutAccessoryView = addButton;      
    } else {
      [annView setAnnotation:annotation];
      
      if([canno totalMarkers] > 1) {
        annView.pinColor = MKPinAnnotationColorPurple;
      } else {
        annView.pinColor = MKPinAnnotationColorRed;
      }      
    }
    
    return annView;
  }
  
  return nil;
}
 
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  if([view.annotation isKindOfClass:[AssetClusterAnnotation class]]) {
    AssetClusterAnnotation *annotation = view.annotation;
        
    ListClusterAnnotationsController *listView = [[ListClusterAnnotationsController alloc] init];
    [listView setTitle:@"Cluster Contents"];
    [listView setAnnotationContents:annotation.annotations];
    [self.navigationController pushViewController:listView animated:YES];
    [listView release];
  }
}
@end
