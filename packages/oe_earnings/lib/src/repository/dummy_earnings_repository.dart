import '../config.dart';
import '../models/earning_line.dart';
import '../models/earnings_summary.dart';
import 'earnings_repository.dart';

/// In-memory earnings fixtures. Does not perform network I/O.
class DummyEarningsRepository implements EarningsRepository {
  DummyEarningsRepository({
    OeEarningsConfig? config,
    EarningsSummary? summary,
    List<EarningLine>? lines,
  })  : config = config ?? const OeEarningsConfig(),
        _summary = summary ?? fixtureSummary,
        _lines = List<EarningLine>.unmodifiable(lines ?? fixtureLines);

  factory DummyEarningsRepository.empty({OeEarningsConfig? config}) {
    return DummyEarningsRepository(
      config: config,
      summary: EarningsSummary.empty(),
      lines: const <EarningLine>[],
    );
  }

  static const EarningsSummary fixtureSummary = EarningsSummary(
    today: 205.5,
    week: 295.5,
    currency: 'INR',
  );

  static final List<EarningLine> fixtureLines = <EarningLine>[
    EarningLine(
      orderId: 'OE-1001',
      amount: 85.5,
      completedAt: DateTime.utc(2026, 9, 18, 10, 30),
    ),
    EarningLine(
      orderId: 'OE-1002',
      amount: 120,
      completedAt: DateTime.utc(2026, 9, 18, 12, 5),
    ),
    EarningLine(
      orderId: 'OE-1003',
      amount: 90,
      completedAt: DateTime.utc(2026, 9, 16, 18, 40),
    ),
  ];

  final OeEarningsConfig config;
  final EarningsSummary _summary;
  final List<EarningLine> _lines;

  @override
  Future<EarningsSummary> fetchSummary() async => _summary;

  @override
  Future<List<EarningLine>> fetchLines() async => _lines;
}
