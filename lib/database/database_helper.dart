
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
  DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // ============================================
  // DATABASE CONNECTION
  // ============================================

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(
      databasePath,
      'insurance_sales.db',
    );

    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  // ============================================
  // CREATE DATABASE
  // ============================================

  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer',
        account_status TEXT NOT NULL DEFAULT 'active'
      )
    ''');

    await db.execute('''
      CREATE TABLE password_resets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        otp TEXT NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await _createAdminRequestsTable(db);
  }

  Future<void> _createAdminRequestsTable(
      DatabaseExecutor db,
      ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        requested_at TEXT NOT NULL,
        reviewed_at TEXT,
        FOREIGN KEY (user_id)
          REFERENCES users(id)
          ON DELETE CASCADE
      )
    ''');
  }

  // ============================================
  // DATABASE UPGRADE
  // ============================================

  Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS password_resets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL,
          otp TEXT NOT NULL,
          expires_at INTEGER NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await _createAdminRequestsTable(db);
    }

    if (oldVersion < 4) {
      // Add account status without deleting
      // existing registered users.
      final columns =
      await db.rawQuery('PRAGMA table_info(users)');

      final hasAccountStatus = columns.any(
            (column) => column['name'] == 'account_status',
      );

      if (!hasAccountStatus) {
        await db.execute('''
          ALTER TABLE users
          ADD COLUMN account_status TEXT NOT NULL
          DEFAULT 'active'
        ''');
      }
    }
  }

  // ============================================
  // ROLE-BASED REGISTRATION
  // ============================================

  // Main registration method.
  //
  // Checks selected role first and delegates
  // to the corresponding registration function.

  Future<int> registerWithRole({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String selectedRole,
  }) async {
    final role = selectedRole.trim().toLowerCase();

    if (role == 'admin') {
      return registerAdmin(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
    } else if (role == 'customer') {
      return registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
    } else {
      throw ArgumentError(
        'Invalid role. Select Customer or Administrator.',
      );
    }
  }

  // ============================================
  // CUSTOMER REGISTRATION
  // ============================================

  Future<int> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await database;

    return db.insert(
      'users',
      {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'role': 'customer',
        'account_status': 'active',
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================
  // ADMINISTRATOR REGISTRATION
  // ============================================

  // Administrator registration is different
  // from customer registration.
  //
  // The user is saved with pending status.
  // Administrator privileges are activated
  // only after approval.

  Future<int> registerAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await database;

    return db.transaction((txn) async {
      final userId = await txn.insert(
        'users',
        {
          'full_name': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'password': password,
          'role': 'admin',
          'account_status': 'active',
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await txn.insert(
        'admin_requests',
        {
          'user_id': userId,
          'status': 'pending',
          'requested_at':
          DateTime.now().toIso8601String(),
        },
      );

      return userId;
    });
  }

  // ============================================
  // ADMIN ACCOUNT PROVISIONING
  // ============================================

  // Trusted development/provisioning only.
  // Never expose this to public registration.

  Future<int> createAdminAccount({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await database;

    return db.insert(
      'users',
      {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'role': 'admin',
        'account_status': 'active',
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================
  // REQUEST ADMIN ACCESS
  // ============================================

  Future<void> requestAdminAccess(int userId) async {
    final db = await database;

    await db.transaction((txn) async {
      final users = await txn.query(
        'users',
        columns: ['role'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        throw StateError('User does not exist.');
      }

      if (users.first['role'] == 'admin') {
        throw StateError(
          'User is already an administrator.',
        );
      }

      await txn.insert(
        'admin_requests',
        {
          'user_id': userId,
          'status': 'pending',
          'requested_at':
          DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await txn.update(
        'users',
        {'account_status': 'pending_admin'},
        where: 'id = ?',
        whereArgs: [userId],
      );
    });
  }

  // ============================================
  // APPROVE ADMIN REQUEST
  // ============================================

  // Must be invoked only through a trusted
  // administration process.

  Future<bool> approveAdminRequest(
      int requestId,
      ) async {
    final db = await database;

    return db.transaction((txn) async {
      final requests = await txn.query(
        'admin_requests',
        columns: ['user_id'],
        where: 'id = ? AND status = ?',
        whereArgs: [requestId, 'pending'],
        limit: 1,
      );

      if (requests.isEmpty) return false;

      final userId = requests.first['user_id'] as int;

      final updated = await txn.update(
        'users',
        {
          'role': 'admin',
          'account_status': 'active',
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (updated == 0) return false;

      await txn.update(
        'admin_requests',
        {
          'status': 'approved',
          'reviewed_at':
          DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND status = ?',
        whereArgs: [requestId, 'pending'],
      );

      return true;
    });
  }

  // ============================================
  // REJECT ADMIN REQUEST
  // ============================================

  Future<bool> rejectAdminRequest(
      int requestId,
      ) async {
    final db = await database;

    return db.transaction((txn) async {
      final requests = await txn.query(
        'admin_requests',
        columns: ['user_id'],
        where: 'id = ? AND status = ?',
        whereArgs: [requestId, 'pending'],
        limit: 1,
      );

      if (requests.isEmpty) return false;

      final userId = requests.first['user_id'] as int;

      await txn.update(
        'users',
        {
          'role': 'customer',
          'account_status': 'active',
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      await txn.update(
        'admin_requests',
        {
          'status': 'rejected',
          'reviewed_at':
          DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND status = ?',
        whereArgs: [requestId, 'pending'],
      );

      return true;
    });
  }

  // ============================================
  // GET ADMIN REQUESTS
  // ============================================

  Future<List<Map<String, dynamic>>>
  getPendingAdminRequests() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        ar.id AS request_id,
        ar.user_id,
        u.full_name,
        u.email,
        u.phone,
        ar.status,
        ar.requested_at
      FROM admin_requests ar
      INNER JOIN users u
        ON u.id = ar.user_id
      WHERE ar.status = ?
      ORDER BY ar.requested_at ASC
    ''', ['pending']);
  }

  Future<List<Map<String, dynamic>>>
  getAdminRequests() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        ar.id AS request_id,
        ar.user_id,
        u.full_name,
        u.email,
        u.role,
        ar.status,
        ar.requested_at,
        ar.reviewed_at
      FROM admin_requests ar
      INNER JOIN users u
        ON u.id = ar.user_id
      ORDER BY ar.requested_at DESC
    ''');
  }

  // ============================================
  // CHECK ADMINISTRATOR ROLE
  // ============================================

  Future<bool> isAdmin(int userId) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where:
      'id = ? AND role = ? AND account_status = ?',
      whereArgs: [
        userId,
        'admin',
        'active',
      ],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ============================================
  // GET ADMINISTRATORS
  // ============================================

  Future<List<Map<String, dynamic>>> getAdmins() async {
    final db = await database;

    return db.query(
      'users',
      columns: [
        'id',
        'full_name',
        'email',
        'phone',
        'role',
        'account_status',
      ],
      where: 'role = ? AND account_status = ?',
      whereArgs: ['admin', 'active'],
      orderBy: 'full_name ASC',
    );
  }

  // ============================================
  // LOGIN
  // ============================================

  Future<Map<String, dynamic>?> loginUser(
      String email,
      String password,
      ) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: [
        'id',
        'full_name',
        'email',
        'phone',
        'role',
        'account_status',
      ],
      where:
      'email = ? AND password = ? AND account_status = ?',
      whereArgs: [
        email.trim().toLowerCase(),
        password,
        'active',
      ],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  // ============================================
  // FIND USER BY EMAIL
  // ============================================

  Future<Map<String, dynamic>?> findUserByEmail(
      String email,
      ) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: [
        'id',
        'full_name',
        'email',
        'phone',
        'role',
        'account_status',
      ],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  // ============================================
  // CHECK EMAIL EXISTS
  // ============================================

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ============================================
  // GET USERS
  // ============================================

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;

    return db.query(
      'users',
      columns: [
        'id',
        'full_name',
        'email',
        'phone',
        'role',
        'account_status',
      ],
      orderBy: 'full_name ASC',
    );
  }

  // ============================================
  // SAVE PASSWORD RESET OTP
  // ============================================

  Future<void> savePasswordResetOtp(
      String email,
      String otp,
      ) async {
    final db = await database;

    final normalisedEmail =
    email.trim().toLowerCase();

    final expiresAt = DateTime.now()
        .add(const Duration(minutes: 5))
        .millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.delete(
        'password_resets',
        where: 'email = ?',
        whereArgs: [normalisedEmail],
      );

      await txn.insert(
        'password_resets',
        {
          'email': normalisedEmail,
          'otp': otp,
          'expires_at': expiresAt,
        },
      );
    });
  }

  // ============================================
  // VERIFY PASSWORD RESET OTP
  // ============================================

  Future<bool> verifyPasswordResetOtp(
      String email,
      String otp,
      ) async {
    final db = await database;

    final normalisedEmail =
    email.trim().toLowerCase();

    final result = await db.query(
      'password_resets',
      where: 'email = ? AND otp = ?',
      whereArgs: [normalisedEmail, otp.trim()],
      limit: 1,
    );

    if (result.isEmpty) return false;

    final expiresAt =
    result.first['expires_at'] as int;

    final now =
        DateTime.now().millisecondsSinceEpoch;

    if (now >= expiresAt) {
      await db.delete(
        'password_resets',
        where: 'email = ?',
        whereArgs: [normalisedEmail],
      );

      return false;
    }

    return true;
  }

  // ============================================
  // RESET PASSWORD
  // ============================================

  Future<bool> resetPassword(
      String email,
      String newPassword, {
        required String otp,
      }) async {
    final db = await database;

    final normalisedEmail =
    email.trim().toLowerCase();

    return db.transaction((txn) async {
      final resets = await txn.query(
        'password_resets',
        where: 'email = ? AND otp = ?',
        whereArgs: [
          normalisedEmail,
          otp.trim(),
        ],
        limit: 1,
      );

      if (resets.isEmpty) return false;

      final expiresAt =
      resets.first['expires_at'] as int;

      if (DateTime.now().millisecondsSinceEpoch >=
          expiresAt) {
        await txn.delete(
          'password_resets',
          where: 'email = ?',
          whereArgs: [normalisedEmail],
        );
        return false;
      }

      final updated = await txn.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [normalisedEmail],
      );

      if (updated == 0) return false;

      await txn.delete(
        'password_resets',
        where: 'email = ?',
        whereArgs: [normalisedEmail],
      );

      return true;
    });
  }

  // ============================================
  // CLOSE DATABASE
  // ============================================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
