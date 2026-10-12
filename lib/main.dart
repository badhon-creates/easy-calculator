import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/data/repositories/local_session_repository.dart';
import 'package:easy_calculator/features/calculator/domain/repositories/session_repository.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:easy_calculator/features/history/data/repositories/local_history_repository.dart';
import 'package:easy_calculator/features/history/domain/repositories/history_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final historyRepository = LocalHistoryRepository();
  final sessionRepository = LocalSessionRepository();

  runApp(
    EasyCalculatorApp(
      historyRepository: historyRepository,
      sessionRepository: sessionRepository,
    ),
  );
}

/// Root application widget configuring themes and dependency injection.
class EasyCalculatorApp extends StatelessWidget {
  const EasyCalculatorApp({
    super.key,
    this.historyRepository,
    this.sessionRepository,
  });

  final HistoryRepository? historyRepository;
  final SessionRepository? sessionRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalculatorCubit>(
      create: (context) => CalculatorCubit(
        historyRepository: historyRepository ?? LocalHistoryRepository(),
        sessionRepository: sessionRepository ?? LocalSessionRepository(),
        autoRestore: true,
      ),
      child: MaterialApp(
        title: 'Easy Calculator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const CalculatorScreen(),
      ),
    );
  }
}
