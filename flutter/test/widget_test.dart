// Contrôles du chapitre 17 : la route de la vue de carte, la garde de position
// et l'encodage de l'adresse d'itinéraire.
//
// Le test livré par `flutter create` vérifiait un compteur que cette
// application n'a jamais eu : il échouait depuis la création du projet. Il est
// remplacé par des contrôles de ce que le chapitre enseigne réellement, et qui
// ne demandent ni réseau ni vue de plateforme.

import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/models/activity_model.dart';
import 'package:testflutter/views/google_map/google_map_view.dart';

void main() {
  test('la vue de carte déclare sa route nommée', () {
    expect(GoogleMapView.routeName, '/google-map');
  });

  test('une activité peut porter une position dont l\'adresse est nulle', () {
    final activite = Activity(
      name: 'Le Louvre',
      city: 'Paris',
      image: 'louvre.jpg',
      price: 12,
      location: LocationActivity(),
    );
    // La garde posée en C17-L01 teste `location`, pas ses champs : une
    // position présente n'implique pas une adresse présente.
    expect(activite.location, isNotNull);
    expect(activite.location!.address, isNull);
  });

  test('sans position, la garde de C17-L01 désactive la navigation', () {
    final activite = Activity(
      name: 'Balade',
      city: 'Paris',
      image: 'balade.jpg',
      price: 0,
    );
    expect(activite.location == null, isTrue);
  });

  test('l\'adresse encodée arrive entière dans l\'URL d\'itinéraire', () {
    const adresse = 'Bâtiment #12, 3 Rue Legendre, Paris';

    final sansEncodage = Uri.parse('google.navigation:q=$adresse');
    // Le `#` coupe l'adresse : tout ce qui suit part dans le fragment.
    expect(sansEncodage.fragment, isNotEmpty);

    final avecEncodage = Uri.parse(
      'google.navigation:q=${Uri.encodeComponent(adresse)}',
    );
    expect(avecEncodage.fragment, isEmpty);
    expect(Uri.decodeComponent(avecEncodage.path.substring(2)), adresse);
  });
}
