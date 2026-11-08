import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mora_y_miel/data/models/receta.dart';
import 'package:mora_y_miel/data/repositories/recetas_repository.dart';
import 'package:mora_y_miel/data/sources/api_exception.dart';
import 'package:mora_y_miel/data/sources/recetas_api.dart';
import 'package:mora_y_miel/providers/estado_peticion.dart';
import 'package:mora_y_miel/providers/recetas_provider.dart';

const _listado = {
  'meals': [
    {'strMeal': 'Apple Frangipan Tart', 'strMealThumb': 'https://x/a.jpg', 'idMeal': '52768'},
    {'strMeal': 'Banana Pancakes', 'strMealThumb': 'https://x/b.jpg', 'idMeal': '52855'},
  ],
};

const _detalle = {
  'meals': [
    {
      'idMeal': '52768',
      'strMeal': 'Apple Frangipan Tart',
      'strCategory': 'Dessert',
      'strArea': 'British',
      'strInstructions': 'Preheat the oven.\r\nBake for 20 minutes.',
      'strMealThumb': 'https://x/a.jpg',
      'strYoutube': '',
      'strIngredient1': 'Butter',
      'strMeasure1': '175g',
      'strIngredient2': 'Apples',
      'strMeasure2': '3',
      'strIngredient3': '',
      'strMeasure3': ' ',
      'strIngredient4': null,
      'strMeasure4': null,
    },
  ],
};

RecetasApi _api(MockClientHandler handler) =>
    RecetasApi(cliente: MockClient(handler));

http.Response _ok(Object json) => http.Response(jsonEncode(json), 200);

void main() {
  group('Modelos (mapeo JSON)', () {
    test('RecetaResumen convierte idMeal de texto a int', () {
      final r = RecetaResumen.fromJson(
        (_listado['meals']! as List).first as Map<String, dynamic>,
      );
      expect(r.id, 52768);
      expect(r.nombre, 'Apple Frangipan Tart');
      expect(r.fotoPreview, 'https://x/a.jpg/preview');
      expect(RecetaResumen.fromJson(r.toJson()).toJson(), r.toJson());
    });

    test('RecetaDetalle junta strIngredientN en una lista y omite vacíos', () {
      final d = RecetaDetalle.fromJson(
        (_detalle['meals']! as List).first as Map<String, dynamic>,
      );
      expect(d.ingredientes, hasLength(2));
      expect(d.ingredientes.first.nombre, 'Butter');
      expect(d.ingredientes.first.medida, '175g');
      expect(d.video, isNull);
      expect(d.pasos, ['Preheat the oven.', 'Bake for 20 minutes.']);
    });

    test('RecetaDetalle: toJson -> fromJson conserva los datos', () {
      final d = RecetaDetalle.fromJson(
        (_detalle['meals']! as List).first as Map<String, dynamic>,
      );
      expect(RecetaDetalle.fromJson(d.toJson()).toJson(), d.toJson());
    });
  });

  group('RecetasApi (errores)', () {
    test('pide el endpoint de postres', () async {
      final api = _api((req) async {
        expect(req.url.toString(), endsWith('/filter.php?c=Dessert'));
        return _ok(_listado);
      });
      expect(await api.obtenerPostres(), hasLength(2));
    });

    test('sin red -> ApiException de tipo sinConexion', () {
      final api = _api((_) async => throw const SocketException('sin red'));
      expect(
        api.obtenerPostres(),
        throwsA(isA<ApiException>().having((e) => e.esDeRed, 'esDeRed', true)),
      );
    });

    test('HTTP 500 -> ApiException de tipo servidor', () {
      final api = _api((_) async => http.Response('error', 500));
      expect(
        api.obtenerPostres(),
        throwsA(
          isA<ApiException>().having((e) => e.tipo, 'tipo', TipoErrorApi.servidor),
        ),
      );
    });

    test('detalle inexistente ({"meals": null}) -> noEncontrado', () {
      final api = _api((_) async => _ok({'meals': null}));
      expect(
        api.obtenerDetalle(1),
        throwsA(
          isA<ApiException>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorApi.noEncontrado,
          ),
        ),
      );
    });
  });

  group('RecetasProvider (estados)', () {
    RecetasProvider provider(MockClientHandler h) =>
        RecetasProvider(RecetasRepository(api: _api(h)));

    test('Cargando -> Exito', () async {
      final p = provider((_) async => _ok(_listado));
      final vistos = <EstadoPeticion<List<RecetaResumen>>>[];
      p.addListener(() => vistos.add(p.estado));
      await p.cargar();
      expect(vistos.first, isA<Cargando<List<RecetaResumen>>>());
      expect(p.estado, isA<Exito<List<RecetaResumen>>>());
      expect(p.visibles, hasLength(2));
    });

    test('Cargando -> Fallo (sin red)', () async {
      final p = provider((_) async => throw const SocketException('x'));
      await p.cargar();
      final f = p.estado as Fallo<List<RecetaResumen>>;
      expect(f.esDeRed, isTrue);
    });

    test('la búsqueda filtra localmente', () async {
      final p = provider((_) async => _ok(_listado));
      await p.cargar();
      p.buscar('banana');
      expect(p.visibles.single.nombre, 'Banana Pancakes');
    });

    test('pull-to-refresh no vuelve a Cargando si ya hay datos', () async {
      final p = provider((_) async => _ok(_listado));
      await p.cargar();
      final vistos = <EstadoPeticion<List<RecetaResumen>>>[];
      p.addListener(() => vistos.add(p.estado));
      await p.cargar(refrescar: true);
      expect(vistos.whereType<Cargando<List<RecetaResumen>>>(), isEmpty);
    });
  });
}
