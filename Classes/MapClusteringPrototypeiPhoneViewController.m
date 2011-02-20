//
//	MapClusteringPrototypeiPhoneViewController.m
//	MapClusteringPrototypeiPhone
//
//	Created by Vlado Grancaric on 01/07/10.
//	Modifications by Sadat Rahman on 20/02/2011.
//	Copyright VLADZZ
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//


#import "MapClusteringPrototypeiPhoneViewController.h"
#import "ListClusterAnnotationsController.h"
#import "AssetClusterAnnotation.h"
#import "AnnotationClusterer.h"
#import "AssetController.h"


#define kCenterPointLatitude  -37.814836
#define kCenterPointLongitude 144.957025

#define kSpanDeltaLatitude    0.007798
#define kSpanDeltaLongitude   0.006866


@interface MapClusteringPrototypeiPhoneViewController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) AnnotationClusterer *annotationClusterer;


- (void)updateAssetsOnRegion:(NSValue *)value;
@end


@implementation MapClusteringPrototypeiPhoneViewController


#pragma mark -
#pragma mark Synthesize Properties
@synthesize operationQueue;
@synthesize annotationClusterer;
@synthesize localMapView;


#pragma mark -
#pragma mark NSObject Methods
- (void)dealloc
{
	[self setOperationQueue:nil];
	[self setAnnotationClusterer:nil];
	[self setLocalMapView:nil];
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController Methods
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setOperationQueue:[[[NSOperationQueue alloc] init] autorelease]];

	CLLocationCoordinate2D centerPoint = {kCenterPointLatitude, kCenterPointLongitude};
	MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(kSpanDeltaLatitude, kSpanDeltaLongitude);
	MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(centerPoint, coordinateSpan);

	[[self localMapView] setRegion:coordinateRegion];
	[[self localMapView] regionThatFits:coordinateRegion];
}


#pragma mark -
#pragma mark MKMapViewDelegate Methods
- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
	NSArray *annotationsArray = [aMapView annotations];
	[aMapView removeAnnotations:annotationsArray];

	MKCoordinateRegion currentRegion = [aMapView region];
	NSValue *regionAsValue = [NSValue valueWithBytes:&currentRegion objCType:@encode(MKCoordinateRegion)];

	NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self
																					  selector:@selector(updateAssetsOnRegion:)
																						object:regionAsValue];
	// Cancel any previous operations before we proceed with this one.
	[[self operationQueue] cancelAllOperations];
	[[self operationQueue] addOperation:invocationOperation];

	DO_RELEASE_SAFELY(invocationOperation);
}


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	static NSString *kAnnotationViewIdentifier = @"MKPinAnnotationViewID";

	if (![annotation isKindOfClass:[AssetClusterAnnotation class]])
	{
		return nil;
	}

	MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationViewIdentifier];
	if (pinAnnotationView == nil)
	{
		pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationViewIdentifier] autorelease];

		UIButton *detailDisclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[detailDisclosureButton setTag:1];
		[pinAnnotationView setRightCalloutAccessoryView:detailDisclosureButton];
	}

	[pinAnnotationView setCanShowCallout:YES];
	[pinAnnotationView setAnnotation:annotation];

	AssetClusterAnnotation *assetClusterAnnotation = annotation;
	MKPinAnnotationColor pinAnnotationColor = ([assetClusterAnnotation totalMarkers] > 1) ? MKPinAnnotationColorPurple : MKPinAnnotationColorRed;
	[pinAnnotationView setPinColor:pinAnnotationColor];

	return pinAnnotationView;
}


- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)anAnnotationView calloutAccessoryControlTapped:(UIControl *)aControl
{
	if ([[anAnnotationView annotation] isKindOfClass:[AssetClusterAnnotation class]])
	{
		AssetClusterAnnotation *assetClusterAnnotation = [anAnnotationView annotation];
		ListClusterAnnotationsController *listClusterAnnotationsController = [[ListClusterAnnotationsController alloc] init];
		[listClusterAnnotationsController setTitle:@"Cluster Contents"];
		[listClusterAnnotationsController setAnnotationContents:[assetClusterAnnotation annotations]];
		[[self navigationController] pushViewController:listClusterAnnotationsController animated:YES];
		DO_RELEASE_SAFELY(listClusterAnnotationsController);
	}
}


#pragma mark -
#pragma mark Private Instance Methods
- (void)updateAssetsOnRegion:(NSValue *)value
{
	NSMutableArray *assetItemsArray = [AssetController getAssetsByCoordinateRegion:value];

	if (![self annotationClusterer])
	{
		AnnotationClusterer *anAnnotationClusterer = [[AnnotationClusterer alloc] initWithMapAndAnnotations:[self localMapView]];
		[self setAnnotationClusterer:anAnnotationClusterer];
		DO_RELEASE_SAFELY(anAnnotationClusterer);
	}
	else
	{
		[[self annotationClusterer] removeAnnotations];
	}

	[[self annotationClusterer] addAnnotations:assetItemsArray];
	[[self localMapView] addAnnotations:[[self annotationClusterer] clusters]];
}
@end

