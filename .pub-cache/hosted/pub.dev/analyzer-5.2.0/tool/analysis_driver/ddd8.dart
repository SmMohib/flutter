// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:analyzer/dart/analysis/results.dart';
// import 'package:analyzer/dart/element/visitor.dart';
// import 'package:analyzer/file_system/physical_file_system.dart';
// import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
// import 'package:analyzer/src/dart/analysis/byte_store.dart';
// import 'package:collection/collection.dart';
//
// void main() async {
//   final resourceProvider = PhysicalResourceProvider.INSTANCE;
//   final rootPath = '/Users/scheglov/Source/flutter/packages/flutter/lib';
//
//   var byteStore = MemoryByteStore();
//
//   void printByteStoreSize() {
//     final totalBytes = byteStore.map.values.map((e) => e.bytes.length).sum;
//     print('  ByteStore: $totalBytes bytes');
//   }
//
//   Future<void> _doOne() async {
//     final timer = Stopwatch()..start();
//     final collection = AnalysisContextCollectionImpl(
//       includedPaths: [rootPath],
//       resourceProvider: resourceProvider,
//       byteStore: byteStore,
//     );
//
//     print('With analysis contexts');
//     print('  Memory: ${await getMemoryUsage()}');
//
//     final analysisContext = collection.contextFor(rootPath);
//     final analysisSession = analysisContext.currentSession;
//
//     await analysisContext.driver.discoverAvailableFiles();
//     // final filesToProcess = analysisContext.contextRoot.analyzedFiles();
//     final filesToProcess = analysisContext.driver.knownFiles.toList();
//
//     var filesSize = 0;
//     var lastPath = '';
//     for (final path in filesToProcess) {
//       final fileResult = analysisSession.getFile(path);
//       fileResult as FileResult;
//       lastPath = path;
//       filesSize +=
//           analysisContext.driver.fsState.getFileForPath(path).content.length;
//     }
//     print('After asking all files');
//     print('  Known files: ${analysisContext.driver.knownFiles.length}');
//     print('  Content: $filesSize bytes');
//     printByteStoreSize();
//     print('  Memory: ${await getMemoryUsage()}');
//
//     for (final path in filesToProcess) {
//       final unitResult = await analysisSession.getUnitElement(path);
//       unitResult as UnitElementResult;
//       // unitResult.element.accept(_VisitAll());
//       // unitResult.element.classes.map((e) => e.methods).toList();
//       // analysisSession.getParsedUnit(path);
//     }
//
//     print('After asking all libraries');
//     print('  Known files: ${analysisContext.driver.knownFiles.length}');
//     printByteStoreSize();
//     print('  Memory: ${await getMemoryUsage()}');
//
//     for (final path in filesToProcess) {
//       final unitResult = await analysisSession.getUnitElement(path);
//       unitResult as UnitElementResult;
//       unitResult.element.accept(_VisitAll());
//       // unitResult.element.classes.map((e) => e.methods).toList();
//       // analysisSession.getParsedUnit(path);
//     }
//     print('With all elements resynthesized');
//     print('  Memory: ${await getMemoryUsage()}');
//
//     // for (final path in filesToProcess) {
//     //   await analysisContext.currentSession.getResolvedUnit(path);
//     // }
//     // print('After resolving every file');
//     // print('  Memory: ${await getMemoryUsage()}');
//
//     await Future<void>.delayed(const Duration(milliseconds: 1));
//     analysisContext.driver.clearLibraryContext();
//     print('After clearLibraryContext()');
//     print('  Memory: ${await getMemoryUsage()}');
//     // await Future<void>.delayed(const Duration(days: 1));
//
//     {
//       final timer = Stopwatch()..start();
//       await analysisContext.currentSession.getResolvedUnit(lastPath);
//       print('After getResolvedUnit($lastPath)');
//       print('  Timer: ${timer.elapsedMilliseconds} ms');
//       print('  Memory: ${await getMemoryUsage()}');
//     }
//
//     {
//       final timer = Stopwatch()..start();
//       await analysisContext.currentSession.getResolvedUnit(lastPath);
//       print('After getResolvedUnit($lastPath)');
//       print('  Timer: ${timer.elapsedMilliseconds} ms');
//       print('  Memory: ${await getMemoryUsage()}');
//     }
//
//     await analysisContext.currentSession.getUnitElement(lastPath);
//     print('[time: ${timer.elapsedMilliseconds} ms]');
//   }
//
//   for (var i = 0; i < 20; i++) {
//     print('$i ----------------------');
//     await _doOne();
//   }
// }
//
// Future<int> getMemoryUsage() async {
//   var uri = Uri.parse('ws://127.0.0.1:5000/ws');
//   var service = await ServiceProtocol.connect(uri);
//   var vm = await service.call('getVM');
//
//   var total = 0;
//
//   final isolates = vm['isolates'] as List<Object?>;
//   for (final isolateRef in isolates.cast<Map>()) {
//     final rrr = await service.call('getAllocationProfile', {
//       'isolateId': isolateRef['id'],
//       // 'reset': 'false',
//       'gc': 'true',
//     });
//     final members = rrr['members'] as List<Object?>;
//     print(
//       '${'Class'.padLeft(25)}'
//       '${'Instances'.padLeft(12)}'
//       '${'MBytes'.padLeft(12)}',
//     );
//     for (final classHeapStat in members) {
//       classHeapStat as Map<String, Object?>;
//       final classRef = classHeapStat['class'] as Map<String, Object?>;
//       final className = classRef['name'] as String;
//       if (const {
//         '_OneByteString',
//         '_TwoByteString',
//         '_Uint32List',
//         '_List',
//         '_Uint8List',
//         '_GrowableList',
//         '_CompactLinkedHashSet',
//         '_InternalLinkedHashMap',
//         '_Uint8ArrayView',
//         'FunctionTypeImpl',
//         'InterfaceTypeImpl',
//         'ClassElementImpl',
//         'MixinElementImpl',
//         'MethodElementImpl',
//         'FieldElementImpl',
//         'PropertyAccessElementImpl',
//         'ParameterElementImpl',
//         'Reference',
//         'IntegerLiteralImpl',
//         'DoubleLiteralImpl',
//         'CompilationUnitImpl',
//       }.contains(className)) {
//         final instancesCurrent = classHeapStat['instancesCurrent'];
//         final bytesCurrent = classHeapStat['bytesCurrent'] as int;
//         final bytesCurrentMb = bytesCurrent / (1024 * 1024.0);
//         final bytesCurrentMbStr = bytesCurrentMb.toStringAsFixed(2);
//         print(
//           '${className.padLeft(25)}'
//           '${instancesCurrent.toString().padLeft(12)}'
//           '${bytesCurrentMbStr.padLeft(12)}',
//         );
//       }
//     }
//   }
//
//   var isolateGroupsRefs = vm['isolateGroups'] as List<Object?>;
//   for (var isolateGroupRef in isolateGroupsRefs.cast<Map>()) {
//     final heapUsage = await service.call('getIsolateGroupMemoryUsage',
//         {'isolateGroupId': isolateGroupRef['id']});
//     // ignore: avoid_dynamic_calls
//     total += heapUsage['heapUsage'] + heapUsage['externalUsage'] as int;
//   }
//
//   await service.dispose();
//
//   return total;
// }
//
// class ServiceProtocol {
//   final WebSocket socket;
//
//   int _id = 0;
//   final Map<String, Completer<Map>> _completers = {};
//
//   ServiceProtocol._(this.socket) {
//     socket.listen(_handleMessage);
//   }
//
//   Future<Map> call(String method, [Map args = const {}]) {
//     var id = '${++_id}';
//     var completer = Completer<Map>();
//     _completers[id] = completer;
//     var m = <String, dynamic>{
//       'jsonrpc': '2.0',
//       'id': id,
//       'method': method,
//       'args': args
//     };
//     m['params'] = args;
//     var message = jsonEncode(m);
//     socket.add(message);
//     return completer.future;
//   }
//
//   Future dispose() => socket.close();
//
//   void _handleMessage(dynamic message) {
//     if (message is! String) {
//       return;
//     }
//
//     try {
//       var json = jsonDecode(message) as Map<Object?, Object?>;
//       if (json.containsKey('id')) {
//         var id = json['id'];
//         _completers[id]?.complete(json['result'] as Map<Object?, Object?>);
//         _completers.remove(id);
//       }
//     } catch (e) {
//       // ignore
//     }
//   }
//
//   static Future<ServiceProtocol> connect(Uri uri) async {
//     var socket = await WebSocket.connect(uri.toString());
//     return ServiceProtocol._(socket);
//   }
//
//   static Future<int> _findAvailableSocketPort() async {
//     var socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
//     try {
//       return socket.port;
//     } finally {
//       await socket.close();
//     }
//   }
// }
//
// class _VisitAll extends RecursiveElementVisitor<void> {}
