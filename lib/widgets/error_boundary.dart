class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      debugPrint('ErrorBoundary - Error caught: ${details.exception}');
      debugPrint('ErrorBoundary - Stack trace: ${details.stack}');
      
      return Material(
        child: Center(
          child: Text(
            'An error occurred: ${details.exception}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    };
    
    return child;
  }
} 