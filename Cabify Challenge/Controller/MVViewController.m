//
//  ViewController.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 14/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "MVViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import "CustomPinAnnotationView.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "APICabify.h"
#import "Utils.h"
#import "VehiclesCostCollectionView.h"
#import "MKMapView+Utils.h"
#import "DBImageView.h"
#import "AFNetworking.h"


/*!
 * @typedef SELECTIONPOINTTYPE
 * @brief A list of crontol point selected
 * @constant SELECTING_START_POINT selecting start point.
 * @constant SELECTING_END_POINT selecting end point
 */
typedef enum {
    SELECTING_START_POINT = 1,
    SELECTING_END_POINT= 2
} SELECTIONPOINTTYPE;

@interface MVViewController (){
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotationA;
    MKPointAnnotation *selectedPlaceAnnotationB;
    CLPlacemark *placemarkSelectedA;
    CLPlacemark *placemarkSelectedB;
    
    CLLocationManager *locationManager;

    BOOL shouldBeginEditing;
    BOOL updateForPanMap;
    SELECTIONPOINTTYPE selectingPoint;
    
    VehiclesCostCollectionView *resultsVehicles;
}

@end

@implementation MVViewController

#pragma mark -
#pragma mark Init View and Services
- (void)viewDidLoad {
    [super viewDidLoad];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:GEO_KEY];
    shouldBeginEditing = YES;
    updateForPanMap = NO;
    selectingPoint = SELECTING_START_POINT;
    
    [self configureView];
    
    [self getUserLocalizationPermission];
    
    /*[RACObserve(self.activityIndicatorSearchAddress, hidden) subscribeNext:^(NSString *x) {
        [self getEstimateAction:nil];
    }];*/
}

-(void)configureView{
    self.definesPresentationContext = YES;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"searchAddressOrPlace", nil);
    
    self.startPointView.layer.cornerRadius = self.endPointView.layer.cornerRadius = 5;
    self.startPointView.layer.masksToBounds = self.endPointView.layer.masksToBounds = NO;
    self.startPointView.layer.shadowColor = self.endPointView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.startPointView.layer.shadowOffset = self.endPointView.layer.shadowOffset = CGSizeMake(0, 3);
    self.startPointView.layer.shadowOpacity = self.endPointView.layer.shadowOpacity = 0.9f;
    self.startPointView.layer.shadowRadius = self.endPointView.layer.shadowRadius = 5.0;
    
    CGFloat widthDevice = [Utils getSccreenSize].width;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthDevice, heightAction)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    UIImageView *googleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-google"]];
    [footerView addSubview:googleIcon];
    [googleIcon setFrame:CGRectMake((widthDevice/2) - (googleIcon.frame.size.width/2), 10, googleIcon.frame.size.width, googleIcon.frame.size.height)];
    self.searchTableView.tableFooterView = footerView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthDevice, 44)];
    self.searchTableView.tableHeaderView = headerView;
    
    //Para detectar que el usuario está empezando a mover el mapa
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)] ;
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;  // In order to discard dragging when pinching
    [self.mapView addGestureRecognizer:panGesture];
    
    [self hideCalculateCostView:NO];
}

-(void)getUserLocalizationPermission{
    locationManager = [[CLLocationManager alloc] init] ;
    locationManager.delegate = self;
    [locationManager setHeadingFilter: kCLHeadingFilterNone];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [DBImageView clearCache];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [locationManager stopUpdatingLocation];
}


#pragma mark -
#pragma mark UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// On dragging gesture put map in free mode
- (void)handlePanGesture:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && _mapView.region.span.latitudeDelta <= 0.06){
        updateForPanMap = YES;        
        [self.staticPin setHidden:NO];
        [self hideCalculateCostView:YES];
        return;
    }
}


#pragma mark -
#pragma mark MKMapView Delegate

// Cuando vamos cambiando la region del mapa eliminamos la anotación actual porque va a cambiar su ubicación
- (void)mapView:(MKMapView *)theMapView regionWillChangeAnimated:(BOOL)animated {
    
    if (updateForPanMap){
        [self.mapView removeAnnotation:selectingPoint == SELECTING_START_POINT ? selectedPlaceAnnotationA : selectedPlaceAnnotationB];
        [self.staticPin setHidden:NO];
    }
}

// Cuando ya ha terminado de cambiar la region buscamos la info del punto y añadimos anotación
- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated {
    
    //Si el usuario a empezado a mover el mapa, se empieza a refrescar las coordenadas cuando suelta
    if (updateForPanMap){
        [self coordinateLocationApi:theMapView.region.center andRecenter:NO];
        updateForPanMap = NO;
    }
}

//Cuando se obtiene la ubicación del usuario si está disponible, la mostramos
- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    if (selectedPlaceAnnotationA == nil && aUserLocation.coordinate.longitude != 0.0)
        [self centerMapToUserLocation:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != self.mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"SPGooglePlacesAutocompleteAnnotation";
    CustomPinAnnotationView *annotationView = (CustomPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[CustomPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    annotationView.canShowCallout = NO;
    annotationView.imageView.image= [UIImage imageNamed:annotation == selectedPlaceAnnotationA? @"pin-a" : @"pin-b"];
    
    CGPoint p = [mapViewIn convertCoordinate:annotation.coordinate toPointToView:self.view];
    [self.staticPin setFrame:CGRectMake(self.staticPin.frame.origin.x, p.y, self.staticPin.frame.size.width, self.staticPin.frame.size.height)];
    
    return annotationView;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MKUserLocation class]])
        return;
    
    if (view.annotation == selectedPlaceAnnotationA)
        [self activateStartingPoint:nil];
    else
        [self activateEndpoint:nil];
}


#pragma mark -
#pragma mark UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.textLabel.numberOfLines = 2;
    }
    
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [self showLoading];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorNoAddress", nil)
                                  andMessage:error.localizedDescription];
            
        } else if (placemark) {
            [self coordinateLocationApi:placemark.location.coordinate andRecenter:YES];
            
        } else {
            [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorNoAddress", nil)
                                  andMessage:nil];
        }
        [self removeLoading];
    }];
    [self.searchTableView deselectRowAtIndexPath:indexPath animated:NO];
    [self dismissSearchControllerWhileStayingActive];
}

#pragma mark -
#pragma mark UISearchController Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString length] >2){
        [self handleSearchForSearchString:searchString];
    }
}

- (void)willPresentSearchController:(UISearchController *)searchController{
    updateForPanMap = NO;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchController setActive:YES];
        [self.mapView removeAnnotation:selectingPoint == SELECTING_START_POINT ? selectedPlaceAnnotationA : selectedPlaceAnnotationB];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchTableView.hidden = NO;
        self.searchTableView.alpha = 0.8f;
        [self.view bringSubviewToFront:self.searchTableView];
        [UIView commitAnimations];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissSearchControllerWhileStayingActive];
}


#pragma mark -
#pragma mark Search Address Methods
- (void)dismissSearchControllerWhileStayingActive {
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchTableView.alpha = 0.0;
    self.searchTableView.hidden = YES;
    [UIView commitAnimations];
    
    [self.searchController.searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    [self.searchController.searchBar removeFromSuperview];
    self.searchController.searchBar.hidden = YES;
    
}

//Busca una dirección con la api de google a partir del criterio de búsqueda
- (void)handleSearchForSearchString:(NSString *)searchString {
    if (![Utils isNetoworkConnected]) {
        [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorNetwork", nil) andMessage:nil];
        return;
    }
    searchQuery.location = self.mapView.userLocation.coordinate;
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorNoAddress", nil)
                                  andMessage:error.localizedDescription];
        } else {
            searchResultPlaces = places;
            [self.searchTableView reloadData];
        }
    }];
}

//Se ha seleccionado una dirección en los resultados de búsqueda o a través de mover el pin por el mapa
- (void)addressSelected:(NSString *)startAddress{
    if (selectingPoint == SELECTING_START_POINT){
        [self.startPointSearchButton setTitle:startAddress forState:UIControlStateNormal];
        if (self.endPointView.hidden == YES){
            [self showEndPointView];
            //[self performSelector:@selector(showEndPointView) withObject:nil afterDelay:0.8f];
        }
    } else {
        [self.endPointSearchButton setTitle:startAddress forState:UIControlStateNormal];
    }
    if (resultsVehicles != nil && !updateForPanMap){
        [self performSelector:@selector(getEstimateAction:) withObject:nil afterDelay:0.5f];
    }
}

#pragma mark -
#pragma mark Map Methods
//Obtiene un placeMark para unas coordenadas dadas con la API de Mapas de Apple
-(void) coordinateLocationApi:(CLLocationCoordinate2D)coordinate andRecenter:(BOOL)recenter{
    if ([Utils isNetoworkConnected]) {
        [self showLoading];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        [geocoder reverseGeocodeLocation:aLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           [self removeLoading];
                           dispatch_async(dispatch_get_main_queue(),^ {
                               // do stuff with placemarks on the main thread
                               if (placemarks.count == 1) {
                                   CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                   NSString *locatedAt = [Utils getAddressFromPlacemark:placemark];
                                   [self addPlacemarkAnnotationToMap:placemark addressString:locatedAt];
                                   if (recenter) [_mapView centerMapToCoordinate:placemark.location.coordinate];
                                   [self addressSelected:locatedAt];
                               }
                           });
                       }];
    } else {
        [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorNetwork", nil) andMessage:nil];
    }
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    
    [self.mapView removeAnnotation:selectingPoint == SELECTING_START_POINT ? selectedPlaceAnnotationA : selectedPlaceAnnotationB];
    [self.staticPin setHidden:YES];
    MKPointAnnotation *selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
    if (selectingPoint == SELECTING_START_POINT){
        selectedPlaceAnnotationA = selectedPlaceAnnotation;
        placemarkSelectedA = placemark;
    } else {
        selectedPlaceAnnotationB = selectedPlaceAnnotation;
        placemarkSelectedB = placemark;
    }
    if (selectedPlaceAnnotationA != nil && selectedPlaceAnnotationB != nil)
        [self showCalculateCostView:YES];
    
}


#pragma mark -
#pragma mark UI Actions Methods

// Si la acción es a través de pulsar sobre el botón de ubicación, buscamos la dirección y lo asignamos a la selección del punto actual
- (IBAction)centerMapToUserLocation:(id)sender {
    if (_mapView.userLocation != nil && _mapView.userLocation.coordinate.longitude != 0.0){
        [_mapView centerMapToCoordinate:_mapView.userLocation.coordinate];
        if (sender != nil){
            [self coordinateLocationApi:_mapView.userLocation.coordinate andRecenter:NO];
        }
    }
}

//Queremos asignar el punto de origen del trayecto
- (IBAction)activateStartingPoint:(id)sender{
    if (placemarkSelectedA != nil)
        [_mapView centerMapToCoordinate:placemarkSelectedA.location.coordinate];
    
    if (selectingPoint == SELECTING_START_POINT){
        self.searchController.searchBar.hidden = NO;
        [self.startPointView addSubview:self.searchController.searchBar];
        [self.searchController.searchBar becomeFirstResponder];
    } else {
        [self desactivateViewPoint:self.endPointView];
        self.startPointView.alpha = 1.0f;
        [self.view bringSubviewToFront:self.startPointView];
    }
    
    [self.userLocationButton setHidden:NO];
    selectingPoint = SELECTING_START_POINT;
}

//Queremos asignar el punto de fin del trayecto
- (IBAction)activateEndpoint:(id)sender{
    if (placemarkSelectedB != nil)
        [_mapView centerMapToCoordinate:placemarkSelectedB.location.coordinate];
    
    if (selectingPoint == SELECTING_END_POINT){
        self.searchController.searchBar.hidden = NO;
        [self.endPointView addSubview:self.searchController.searchBar];
        [self.searchController.searchBar becomeFirstResponder];
    } else {
        [self desactivateViewPoint:self.startPointView];
        self.endPointView.alpha = 1.0f;
        [self.view bringSubviewToFront:self.endPointView];
    }
    
    [self.userLocationButton setHidden:YES];
    selectingPoint = SELECTING_END_POINT;
}

//Obtiene la estimación para un punto de origen y otro de fin
- (IBAction)getEstimateAction:(id)sender{
    
    if ([Utils isNetoworkConnected]) {
            
        if (resultsVehicles != nil){
            [resultsVehicles removeFromSuperview];
            resultsVehicles = nil;
        }
        [self showLoadingGetEstimate];
        [_mapView zoomToFitMapAnnotations];
        [[[[APICabify getEstimateWithStart:placemarkSelectedA.location.coordinate andEnd:placemarkSelectedB.location.coordinate]
           throttle:0.5f]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(NSArray *vehicles) {
             VehiclesCostCollectionView *collectionView = [[VehiclesCostCollectionView alloc] initWithFrame:self.getEstimateView.bounds];
             [self.getEstimateView addSubview:collectionView];
             [collectionView setNeedsDisplay];
             [collectionView setVehicles:vehicles];
             [self hideLoadingGetEstimate];
             resultsVehicles = collectionView;
             
         } error:^(NSError *error) {
             [self hideLoadingGetEstimate];
             [self.getEstimateButton setHidden:NO];
             [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorComunication", nil)
                                   andMessage:error.localizedDescription];
         }];
    
    }else{
        [Utils showMessageErrorWithTitle:NSLocalizedString(@"errorNetwork", nil) andMessage:nil];
    }        
    
}

- (IBAction)clearResults:(id)sender{
    [resultsVehicles removeFromSuperview];
    resultsVehicles = nil;
}

#pragma mark -
#pragma mark About UI Methods

- (void)desactivateViewPoint:(UIView *)view{
    view.alpha = 0.6f;
}

- (void)showEndPointView{
    if (self.endPointView.hidden == YES){
        self.endPointView.hidden = NO;
        self.verticalSpaceConstraint.constant += 40;
        [UIView animateWithDuration:0.5f animations:^{
            [self.view layoutIfNeeded];
        }];
        [self activateEndpoint:nil];
    }
}

- (void)showCalculateCostView:(BOOL)animated{
    if (![self calculateCostIsActive]){
        self.bottomSpaceConstraint.constant = 0;
        if (animated){
            [UIView animateWithDuration:0.3f animations:^{
                [self.view layoutIfNeeded];
            }];
        } else
            [self.view layoutIfNeeded];
    }
}

- (void)hideCalculateCostView:(BOOL)animated{
    if ([self calculateCostIsActive]){
        self.bottomSpaceConstraint.constant = -heightFooter;
        if (animated){
            [UIView animateWithDuration:0.3f animations:^{
                [self.view layoutIfNeeded];
            }];
        } else
            [self.view layoutIfNeeded];
    }
}

- (BOOL)calculateCostIsActive{
    return self.bottomSpaceConstraint.constant >= 0;
}

- (void)showLoadingGetEstimate{
    [self.getEstimateButton setHidden:YES];
    [self.activityIndicatorGetEstimate startAnimating];
}

- (void)hideLoadingGetEstimate{
    [self.activityIndicatorGetEstimate stopAnimating];
}

- (void)showLoading{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationkeyIncreaseNetworkActivity object:nil];
    [self.activityIndicatorSearchAddress startAnimating];
}

- (void)removeLoading{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationkeyDecreaseNetworkActivity object:nil];
    [self.activityIndicatorSearchAddress stopAnimating];
}


@end
