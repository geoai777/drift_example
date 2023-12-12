/// Host where postgre sql server located. Could be ip like 192.168.1.1
/// or host name.
const String pgHost = '192.168.1.1';
/// database should be prematurely created on server via: `createdb book_shelf`
const String pgDatabase = 'book_shelf';
const String pgUser = 'sample_user';
/// it is even better to store this base64 encoded
const String pgPassword = '9775';