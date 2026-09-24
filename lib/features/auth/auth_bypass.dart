class AuthBypass {
  const AuthBypass._();

  /// Provisório: ignora cadastro em análise (status 02 com mensagem de aprovação).
  static const bool pendingApproval = true;

  static bool isPendingApprovalMessage(String message) {
    final msg = message.toLowerCase();
    return msg.contains('anális') ||
        msg.contains('analis') ||
        msg.contains('aprova') ||
        msg.contains('aguard');
  }

  static bool shouldBypass(String status, String message) {
    return pendingApproval &&
        status == '02' &&
        isPendingApprovalMessage(message);
  }
}
