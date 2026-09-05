import '../entities/freelance_entities.dart';

/// Freelance-specific money: the tax vault and the invoice book.
abstract interface class FreelanceRepository {
  Future<TaxVault> getVault();

  /// Sets the fraction of incoming payments auto-reserved for tax, 0–1.
  Future<TaxVault> setReserveRate(double rate);

  /// Moves money between the spendable balance and the vault. A positive
  /// [amount] reserves, a negative one releases.
  Future<TaxVault> adjustReserve(double amount);

  Future<List<Invoice>> getInvoices();

  Future<Invoice> addInvoice(Invoice invoice);

  Future<Invoice> updateInvoice(Invoice invoice);

  Future<void> deleteInvoice(String invoiceId);

  Future<void> markPaid(String invoiceId);

  Future<List<Commitment>> getCommitments();
}
