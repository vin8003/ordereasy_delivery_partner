import '../models/earning_line.dart';
import '../models/earnings_summary.dart';

/// Fetches rider earnings. Implementations may be dummy or remote later.
abstract class EarningsRepository {
  Future<EarningsSummary> fetchSummary();

  Future<List<EarningLine>> fetchLines();
}
