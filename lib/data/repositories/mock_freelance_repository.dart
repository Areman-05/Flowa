import '../../domain/entities/freelance_entities.dart';
import '../../domain/repositories/freelance_repository.dart';

class MockFreelanceRepository implements FreelanceRepository {
  MockFreelanceRepository({
    TaxVault? vault,
    List<Invoice>? invoices,
    List<Commitment>? commitments,
  })  : _vault = vault ?? const TaxVault(reserved: 0, rate: 0.25),
        _invoices = List<Invoice>.from(invoices ?? const []),
        _commitments = List<Commitment>.from(commitments ?? const []);

  TaxVault _vault;
  final List<Invoice> _invoices;
  final List<Commitment> _commitments;

  @override
  Future<TaxVault> getVault() async => _vault;

  @override
  Future<TaxVault> setReserveRate(double rate) async {
    _vault = _vault.copyWith(rate: rate.clamp(0, 1));
    return _vault;
  }

  @override
  Future<TaxVault> adjustReserve(double amount) async {
    final next = _vault.reserved + amount;
    _vault = _vault.copyWith(reserved: next < 0 ? 0 : next);
    return _vault;
  }

  @override
  Future<List<Invoice>> getInvoices() async {
    final items = List<Invoice>.from(_invoices)
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return items;
  }

  @override
  Future<Invoice> addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);
    return invoice;
  }

  @override
  Future<void> markPaid(String invoiceId) async {
    final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
    if (index >= 0) {
      _invoices[index] = _invoices[index].copyWith(status: InvoiceStatus.paid);
    }
  }

  @override
  Future<List<Commitment>> getCommitments() async {
    final items = List<Commitment>.from(_commitments)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return items;
  }
}
