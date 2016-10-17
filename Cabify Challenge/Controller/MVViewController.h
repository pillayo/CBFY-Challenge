//
//  ViewController.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 14/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/*
 *  MVViewController
 *
 *  Discussion:
 *    Principal controller with map and tools for to select start point and end point, calculate estimate cost.
 */
@interface MVViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UISearchResultsUpdating, CLLocationManagerDelegate>

/*!
 * @brief Controlador para búsqueda de una dirección a partir de un punto en el mapa
 */
@property (strong, nonatomic) UISearchController *searchController;

/*!
 * @brief Vista que dibuja un mapa
 */
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

/*!
 * @brief Pin estático para orientar al usuario sobre el punto que quiere seleccionar sobre el mapa
 */
@property (strong, nonatomic) IBOutlet UIImageView *staticPin;

/*!
 * @brief Tabla con los resultados de búsqueda de las direcciones
 */
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;

/*!
 * @brief Vista para seleccionar el punto de origen del trayecto
 */
@property (strong, nonatomic) IBOutlet UIView *startPointView;

/*!
 * @brief Al pulsar se despliega la búsqueda de una dirección para el punto de origen
 */
@property (strong, nonatomic) IBOutlet UIButton *startPointSearchButton;

/*!
 * @brief Vista para seleccionar el punto final del trayecto
 */
@property (strong, nonatomic) IBOutlet UIView *endPointView;

/*!
 * @brief Al pulsar se despliega la búsqueda de una dirección para el punto final
 */
@property (strong, nonatomic) IBOutlet UIButton *endPointSearchButton;

/*!
 * @brief Al pulsar selecciona la posición actual del usuario
 */
@property (strong, nonatomic) IBOutlet UIButton *userLocationButton;

/*!
 * @brief Vista que contiene el botón y los resultados de la estimación para un viaje
 */
@property (strong, nonatomic) IBOutlet UIView *getEstimateView;

/*!
 * @brief Al pulsar obtenemos la estimación para un viaje
 */
@property (strong, nonatomic) IBOutlet UIButton *getEstimateButton;

/*!
 * @brief Indicador para feedback de buscando dirección
 */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorSearchAddress;

/*!
 * @brief Indicador para feedback de calculando estimación
 */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorGetEstimate;

/*!
 * @brief Constraint para poder esconder la vista de obetner estimación
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;

/*!
 * @brief Constraint para poder mostrar la búsqueda del punto de fin cuando ya hemos seleccionado un punto de origen
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;


@end

