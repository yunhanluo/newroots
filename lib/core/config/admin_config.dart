/// Bootstrap admins. Firestore rules also allow this email even before the
/// custom `admin` claim is written.
const kBootstrapAdminEmails = <String>{
  'y@yunhanluo.com',
};

bool isBootstrapAdmin(String? email) {
  final normalized = email?.trim().toLowerCase() ?? '';
  return kBootstrapAdminEmails.contains(normalized);
}
