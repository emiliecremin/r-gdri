print("copernicus dem 0 to 4m");
var copernicus = require('users/loicbaron/aquaculture:copernicus_DEM');
var roi = copernicus.demMinMax;
var bounds = roi.geometry().bounds();
Map.centerObject(roi);


var get_dates = function(collection, month, year, bounds) {
  var filtered = collection.filter(ee.Filter.calendarRange(year, year, 'year'))
                           .filter(ee.Filter.calendarRange(month, month, 'month'))
                           .filterBounds(bounds)

  return ee.List(filtered.toList(filtered.size()).map(function(img){
    return ee.Image(img).date().format()
  }))
}

var dates = get_dates(ee.ImageCollection('COPERNICUS/S2'), 1, 2016, Map.getCenter());
console.log(dates.getInfo());

var s2 = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED');
var filtered = s2
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20))
  .filter(ee.Filter.date('2018-01-01', '2018-12-31'))
  .filterBounds(bounds)
  .select('B.*');
print("Composite median COPERNICUS Sentinel 2");

var composite = filtered.median();

// Display the input composite.
var rgbVis = {
  min: 0.0,
  max: 3000,
  bands: ['B4', 'B3', 'B2'],
};

Map.addLayer(composite, rgbVis)

var gcps = river.merge(aquaculture).merge(forest).merge(crops).merge(built).merge(sand)
  .map(function(f) { return f.set('geomType', f.geometry().type()); })
  .filter(ee.Filter.eq('geomType', 'Point'));

print('gcps', gcps)
// Overlay the point on the image to get training data.
var training = composite.sampleRegions({
  collection: gcps, 
  properties: ['landcover'], 
  scale: 10
});
var masked_composite = composite.updateMask(roi);
// Train a classifier.
var classifier = ee.Classifier.smileRandomForest(50).train({
  features: training,  
  classProperty: 'landcover', 
  inputProperties: masked_composite.bandNames()
});
// // Classify the image.
var classified = masked_composite.classify(classifier);
// Choose a 6-color palette
// Assign a color for each class in the following order
// River, Aquaculture, Forest, Crops, Built, Sand
var palette = ['#1e88e5','#cc6d8f', '#004d40', '#ffc107', '#969695', '#d6c0b9' ];

// Map.addLayer(classified, {min: 0, max: 5, palette: palette}, 'clipped classified 2023');

var mask_aquaculture = classified.eq(1);
var aquaculture = classified.updateMask(mask_aquaculture);
Map.addLayer(aquaculture, {min: 0, max: 5, palette: palette}, 'aquaculture');

// Display the GCPs
// We use the style() function to style the GCPs
// var palette = ee.List(palette);
// var landcover = ee.List([0, 1, 2, 3, 4, 5]);

// var gcpsStyled = ee.FeatureCollection(
//   landcover.map(function(lc){
//     var color = palette.get(landcover.indexOf(lc));
//     var markerStyle = { color: 'white', pointShape: 'diamond', 
//       pointSize: 4, width: 1, fillColor: color};
//     return gcps.map(function(point){
//                   return point.set('style', markerStyle)
//                 })
//       })).flatten();
      
// Map.addLayer(gcpsStyled.style({styleProperty:"style"}), {}, 'GCPs');
// Map.centerObject(gcpsStyled);

// Hold-out accuracy of the aquaculture Random Forest (review D6), version 3: split by labelled feature,
// light on the Earth Engine server ("Too many concurrent aggregations" with v2).
// Paste at the end of the GDRI aquaculture script (after `gcps` and `composite` are defined).
// It does not change `classifier`, `classified` or the export.
// Classes: 0 river, 1 aquaculture, 2 forest, 3 crops, 4 built, 5 sand.
//
// Pixels are sampled ONCE from the labelled features; each feature carries one random number per split
// (r1 ... rN), so all pixels of a feature fall in the same part (training < 0.7, test >= 0.7).
// Each split is printed separately; I compute the means and SDs from the printed values.

var SEEDS = [1, 2, 3, 4, 5];   // use [1, ..., 10] if the console copes
var POOLED = false;            // true: also print the confusion matrix summed over the splits (heavier)

var gcpsR = gcps;
SEEDS.forEach(function(s) { gcpsR = gcpsR.randomColumn('r' + s, s); });
var props = ['landcover'].concat(SEEDS.map(function(s) { return 'r' + s; }));
var pixels = composite.sampleRegions({collection: gcpsR, properties: props, scale: 10});

print('geometry type of the first labelled feature', gcps.first().geometry().type());
print('number of labelled features', gcps.size());
print(gcps.aggregate_histogram('landcover'))
print('pixels sampled', pixels.size());
print('pixels per class', pixels.aggregate_histogram('landcover'));
print('training size', training.size());

var pooled = null;
SEEDS.forEach(function(s) {
  var trainPix = pixels.filter(ee.Filter.lt('r' + s, 0.7));
  var testPix = pixels.filter(ee.Filter.gte('r' + s, 0.7));
  var clf = ee.Classifier.smileRandomForest(50).train({
    features: trainPix,
    classProperty: 'landcover',
    inputProperties: composite.bandNames()
  });
  var cm = testPix.classify(clf).errorMatrix('landcover', 'classification', [0, 1, 2, 3, 4, 5]);
  print('split ' + s, ee.Dictionary({
    overall_accuracy: cm.accuracy(),
    kappa: cm.kappa(),
    aquaculture_producers: ee.Number(cm.producersAccuracy().get([1, 0])),  // omission error = 1 - this
    aquaculture_users: ee.Number(cm.consumersAccuracy().get([0, 1])),      // commission error = 1 - this
    confusion_matrix: cm.array()   // rows = reference, columns = predicted
  }));
  if (POOLED) { pooled = pooled === null ? cm.array() : pooled.add(cm.array()); }
});
if (POOLED) { print('pooled confusion matrix (rows = reference, columns = predicted)', pooled); }


// Resolution per BAND: https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED#bands
Export.image.toDrive({
  image: aquaculture,
  description: 'COPERNICUS_S2_SR_HARMONIZED_Aquaculture_class',
  folder: 'GEE',
  region: roi,
  scale: 10, // Sentinel 2 offers 10m resolution for the selected bands
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13,
});

