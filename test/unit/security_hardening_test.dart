import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_engine.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_lexer.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_parser.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/currency_calculator.dart';
import 'package:easy_calculator/features/history/data/repositories/local_history_repository.dart';
import 'package:easy_calculator/features/math_notes/data/services/share_plus_note_share_service.dart';

void main() {
  group('Security & Input Hardening - Calculator Engine', () {
    const engine = CalculatorEngine();
    const lexer = CalculatorLexer();
    const parser = CalculatorParser();

    test('Rejects expressions exceeding 1000 characters', () {
      final longExpr = '1+' * 501 + '1'; // 1003 characters
      expect(
        () => lexer.tokenize(longExpr),
        throwsA(
          isA<CalculationException>().having(
            (e) => e.message,
            'message',
            contains('maximum length'),
          ),
        ),
      );

      final evalResult = engine.evaluate(longExpr);
      expect(evalResult.isSuccess, isFalse);
      expect(evalResult.errorMessage, contains('maximum length'));
    });

    test('Rejects excessively deep parentheses nesting (> 50 depth)', () {
      final openParens = '(' * 51;
      final closeParens = ')' * 51;
      final nestedExpr = '${openParens}42$closeParens';

      final tokens = lexer.tokenize(nestedExpr);
      expect(
        () => parser.parseToRpn(tokens),
        throwsA(
          isA<CalculationException>().having(
            (e) => e.message,
            'message',
            contains('nesting exceeds maximum depth'),
          ),
        ),
      );

      final result = engine.evaluate(nestedExpr);
      expect(result.isSuccess, isFalse);
    });

    test(
      'Safely handles deeply nested parens within allowed depth (<= 50)',
      () {
        final openParens = '(' * 25;
        final closeParens = ')' * 25;
        final nestedExpr = '${openParens}42$closeParens';

        final result = engine.evaluate(nestedExpr);
        expect(result.isSuccess, isTrue);
        expect(result.value, 42.0);
      },
    );

    test('Never evaluates arbitrary code or scripts', () {
      final payloads = [
        'eval("2+2")',
        'System.exit(0)',
        'import("dart:io")',
        r'${42}',
        '<script>alert(1)</script>',
        'SELECT * FROM notes',
        '__proto__',
      ];

      for (final payload in payloads) {
        final result = engine.evaluate(payload);
        expect(result.isSuccess, isFalse);
      }
    });

    test('Safely catches invalid mathematical domains without app crashes', () {
      final invalidDomains = [
        'sqrt(-4)',
        'ln(0)',
        'ln(-1)',
        'log10(0)',
        'log10(-10)',
        'asin(2)',
        'acos(-1.5)',
        'acosh(0.5)',
        'atanh(1)',
        'atanh(-1)',
        '10 / 0',
        'tan(90)',
        '(-4)^(0.5)',
      ];

      for (final expr in invalidDomains) {
        final result = engine.evaluate(expr);
        expect(
          result.isSuccess,
          isFalse,
          reason: 'Expression "$expr" should have failed safely',
        );
      }
    });

    test('Guards factorial against overflow', () {
      // 170! is ~7.2574e306 (finite)
      final r170 = engine.evaluate('170!');
      expect(r170.isSuccess, isTrue);
      expect(r170.value!.isFinite, isTrue);

      // 171! exceeds IEEE 754 double range and must trigger overflow exception
      final r171 = engine.evaluate('171!');
      expect(r171.isSuccess, isFalse);
      expect(r171.errorMessage, contains('overflow'));
    });
  });

  group('Security & Sanitization - PDF Filenames & Exports', () {
    test('Strips path traversal sequences from exported PDF filenames', () {
      expect(sanitizeNoteFilename('../../../etc/passwd'), isNot(contains('/')));
      expect(
        sanitizeNoteFilename('..\\..\\windows\\system32'),
        isNot(contains('\\')),
      );
      expect(sanitizeNoteFilename('../../../etc/passwd'), 'etcpasswd');
    });

    test('Strips illegal file system characters (< > : " / \\ | ? *)', () {
      const dangerous = 'Math: Notes * [2026] <Draft> | Final?';
      final clean = sanitizeNoteFilename(dangerous);
      expect(clean, isNot(contains(':')));
      expect(clean, isNot(contains('*')));
      expect(clean, isNot(contains('<')));
      expect(clean, isNot(contains('>')));
      expect(clean, isNot(contains('|')));
      expect(clean, isNot(contains('?')));
      expect(clean, isNot(contains(' ')));
    });

    test('Truncates extremely long note titles to 40 characters', () {
      final longTitle = 'A' * 150;
      final clean = sanitizeNoteFilename(longTitle);
      expect(clean.length, 40);
    });

    test('Provides fallback filename if title is only whitespace or illegal characters', () {
      expect(sanitizeNoteFilename('   '), 'Math_Note');
      expect(sanitizeNoteFilename('???///:::***'), 'Math_Note');
      expect(sanitizeNoteFilename(''), 'Math_Note');
    });
  });

  group('Security & Precision - Currency Converter Calculations', () {
    final snapshot = ExchangeRatesSnapshot(
      baseCurrency: 'USD',
      date: '2026-10-14',
      rates: {'USD': 1.0, 'EUR': 0.92, 'BDT': 123.16, 'JPY': 150.0},
      timestamp: DateTime.now(),
      isCached: false,
    );

    test('Handles extremely large currency amounts cleanly without exponential corruption', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 1e12,
        fromCode: 'USD',
        toCode: 'BDT',
        snapshot: snapshot,
      );
      expect(result, isNotNull);
      expect(result!.targetAmount, 123.16e12);
      expect(result.formattedTarget, isNotEmpty);
    });

    test('Rejects non-finite amounts and rates safely', () {
      expect(CurrencyCalculator.parseInputAmount('NaN'), 0.0);
      expect(CurrencyCalculator.parseInputAmount('Infinity'), 0.0);
      expect(CurrencyCalculator.parseInputAmount('-Infinity'), 0.0);
      expect(CurrencyCalculator.formatCurrencyValue(double.nan), '0');
      expect(CurrencyCalculator.formatCurrencyValue(double.infinity), '0');
    });

    test(
      'Same-currency conversion bypasses rate lookup and returns identity',
      () {
        final result = CurrencyCalculator.convert(
          sourceAmount: 500.0,
          fromCode: 'BDT',
          toCode: 'BDT',
          snapshot: snapshot,
        );
        expect(result, isNotNull);
        expect(result!.isSameCurrency, isTrue);
        expect(result.targetAmount, 500.0);
        expect(result.rate, 1.0);
      },
    );

    test(
      'Returns null gracefully when currency pair rate cannot be resolved',
      () {
        final result = CurrencyCalculator.convert(
          sourceAmount: 100.0,
          fromCode: 'XYZ',
          toCode: 'USD',
          snapshot: snapshot,
        );
        expect(result, isNull);
      },
    );
  });

  group('Security & Data Retention - 7-Calendar-Day History Purging', () {
    test(
      'Strict retention: exactly 7 calendar days retained, day 8 is purged',
      () {
        final now = DateTime(2026, 10, 14, 15, 0);

        // Today (Day 0): retained
        expect(
          LocalHistoryRepository.isEntryExpired(
            DateTime(2026, 10, 14, 9, 0),
            now,
          ),
          isFalse,
        );

        // 6 days ago (Day 6): retained
        expect(
          LocalHistoryRepository.isEntryExpired(
            DateTime(2026, 10, 8, 23, 59),
            now,
          ),
          isFalse,
        );

        // Exactly 7 days ago (Day 7): expired
        expect(
          LocalHistoryRepository.isEntryExpired(
            DateTime(2026, 10, 7, 23, 59),
            now,
          ),
          isTrue,
        );

        // 10 days ago: expired
        expect(
          LocalHistoryRepository.isEntryExpired(
            DateTime(2026, 10, 4, 12, 0),
            now,
          ),
          isTrue,
        );

        // Future clock drift: retained safely
        expect(
          LocalHistoryRepository.isEntryExpired(
            DateTime(2026, 10, 15, 10, 0),
            now,
          ),
          isFalse,
        );
      },
    );
  });
}
