/// Stub deep-link parser for future integration.
///
/// Recognised paths: `/send`, `/receive`, `/transaction/:id`.
abstract final class FlowaDeepLinks {
  static DeepLinkRoute? parse(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) {
      return null;
    }
    return switch (segments.first) {
      'send' => const DeepLinkRoute(destination: DeepLinkDestination.send),
      'receive' => const DeepLinkRoute(destination: DeepLinkDestination.receive),
      'transaction' when segments.length > 1 => DeepLinkRoute(
          destination: DeepLinkDestination.transactionDetail,
          id: segments[1],
        ),
      _ => null,
    };
  }
}

enum DeepLinkDestination {
  send,
  receive,
  transactionDetail,
}

class DeepLinkRoute {
  const DeepLinkRoute({required this.destination, this.id});

  final DeepLinkDestination destination;
  final String? id;
}
