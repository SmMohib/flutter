import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';

void main() async {
  final resourceProvider = PhysicalResourceProvider.INSTANCE;

  var rootPath = '/usr/local/google/home/scheglov/Source/fuchsia/'
      'sdk/dart/fuchsia_vfs/lib/src/pseudo_dir.dart';
  final collection = AnalysisContextCollectionImpl(
    includedPaths: [rootPath],
    resourceProvider: resourceProvider,
  );

  final analysisContext = collection.contextFor(rootPath);
  final analysisSession = analysisContext.currentSession;

  final result = await analysisSession.getResolvedUnit(rootPath);
  result as ResolvedUnitResult;
  print(result.errors
      .where((error) => error.errorCode.type != ErrorType.TODO)
      .toList()
      .join('\n'));
}
