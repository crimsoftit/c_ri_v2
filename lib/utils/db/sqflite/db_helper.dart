import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/models/inv_dels_model.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/models/txns_model.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper extends GetxController {
  /// -- constructor --
  // make this a singleton class
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  @override
  void onInit() async {
    saleItemAddedToDb.value = false;
    super.onInit();
  }

  final int version = 1;

  /// -- variables --
  Database? _db;

  final userController = Get.put(CUserController());

  final invTable = 'inventory';
  final txnsTable = 'txns';
  final invDelsForSyncTable = 'invDelsForSyncTable';
  final salesDelsForSyncTable = 'salesDelsForSyncTable';

  final RxBool saleItemAddedToDb = false.obs;

  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    if (_db != null) {
      return _db!;
    }
    _db = await openDatabase(join(await getDatabasesPath(), 'stock.db'),
        onCreate: (database, version) {
      database.execute('''
          CREATE TABLE IF NOT EXISTS $invTable (
            productId INTEGER PRIMARY KEY NOT NULL,
            userId TEXT NOT NULL,
            userEmail TEXT NOT NULL,
            userName TEXT NOT NULL,
            pCode LONGTEXT NOT NULL,
            name TEXT NOT NULL,
            markedAsFavorite INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            qtySold INTEGER NOT NULL,
            qtyRefunded INTEGER NOT NULL,
            buyingPrice REAL NOT NULL,
            unitBp REAL NOT NULL,
            unitSellingPrice REAL NOT NULL,
            lowStockNotifierLimit INTEGER NOT NULL,
            supplierName TEXT NOT NULL,
            supplierContacts TEXT NOT NULL,
            dateAdded CHAR(30) NOT NULL,
            lastModified CHAR(30) NOT NULL,
            isSynced INTEGER NOT NULL,
            syncAction TEXT NOT NULL
            )
          ''');

      database.execute('''
          CREATE TABLE IF NOT EXISTS $txnsTable(
            soldItemId INTEGER PRIMARY KEY AUTOINCREMENT,
            txnId INTEGER NOT NULL,
            userId TEXT NOT NULL,
            userEmail TEXT NOT NULL,
            userName TEXT NOT NULL,
            productId INTEGER NOT NULL,
            productCode LONGTEXT NOT NULL,
            productName TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            qtyRefunded INTEGER NOT NULL,
            refundReason TEXT NOT NULL,
            totalAmount  REAL NOT NULL,
            amountIssued REAL NOT NULL,
            customerBalance REAL NOT NULL,
            unitSellingPrice REAL NOT NULL,
            deposit REAL NOT NULL,
            paymentMethod TEXT NOT NULL,
            customerName TEXT,
            customerContacts TEXT,
            txnAddress LONGTEXT,
            txnAddressCoordinates LONGTEXT,
            lastModified TEXT NOT NULL,
            isSynced INTEGER NOT NULL,
            syncAction TEXT NOT NULL,
            txnStatus TEXT NOT NULL,
            FOREIGN KEY(productId) REFERENCES inventory(productId)
            )          
          ''');

      database.execute('''
          CREATE TABLE IF NOT EXISTS $invDelsForSyncTable (
            itemId INTEGER NOT NULL,
            itemName TEXT NOT NULL,
            itemCategory TEXT NOT NULL,
            isSynced INTEGER NOT NULL,
            syncAction TEXT NOT NULL
          )
        ''');

      database.execute('''
          CREATE TABLE IF NOT EXISTS $salesDelsForSyncTable (
            itemId INTEGER NOT NULL,
            itemName TEXT NOT NULL,
            isSynced INTEGER NOT NULL,
            syncAction TEXT NOT NULL
          )
        ''');
    }, version: version);

    saleItemAddedToDb.value = false;
    return _db!;
  }

  Future testDb() async {
    _db = await openDb();

    var invItem = CInventoryModel.withID(
      CHelperFunctions.generateInvId(),
      userController.user.value.id,
      userController.user.value.email,
      userController.user.value.fullName,
      '4714290023',
      'njugu',
      0,
      200,
      10,
      3,
      1400.00,
      7.0,
      10.0,
      10,
      'pabari',
      '0114 567 890',
      'added: 03/03/2025',
      clock.now().toString(),
      1,
      'none',
    );

    await _db!.execute('INSERT INTO $invTable VALUES (${invItem.productId})');
    await _db!.execute(
        'INSERT INTO $txnsTable VALUES (0, "as23df45", "sindani254@gmail.com", "Manu", "143d", "apples", 13, 15, 10.0, "Cash", "2/1/2022")');
    List inventory = await _db!.rawQuery('select * from inventory');
    List sales = await _db!.rawQuery('select * from sales');
    if (kDebugMode) {
      print(inventory[0].toString());
      print(sales[0].toString());
    }
  }

  /// --- ### CRUD OPERATIONS ON INVENTORY TABLE ### ---

  Future<void> addInventoryItem(CInventoryModel inventoryItem) async {
    // Get a reference to the database.
    final db = _db;

    // Insert the inventoryItem into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same inventoryItem is inserted twice.
    //
    // In this case, replace any previous data.
    await db?.insert(invTable, inventoryItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// -- fetch operation: get all inventory objects from the database --
  Future<List<CInventoryModel>> fetchInventoryItems(String email) async {
    // Get a reference to the database.
    final db = _db;

    // Query the table for inventory list
    final result = await db!.rawQuery(
        'SELECT * FROM $invTable WHERE userEmail = ? ORDER BY quantity ASC',
        [email]);

    //final result = await db!.query(invTable, orderBy: 'productId ASC');

    // Convert the List<Map<String, dynamic> into a List<CInventoryModel>.
    return result.map((json) => CInventoryModel.fromMapObject(json)).toList();
  }

  // fetch operation: get barcode-scanned inventory object from the database
  Future<List<CInventoryModel>> fetchInvItemByCodeAndEmail(
      String code, String email) async {
    final List<Map<String, dynamic>> maps = await _db!.query(
      invTable,
      where: 'pCode = ? and userEmail = ?',
      whereArgs: [code, email],
    );
    return List.generate(maps.length, (i) {
      return CInventoryModel.withID(
        maps[i]['productId'],
        maps[i]['userId'],
        maps[i]['userEmail'],
        maps[i]['userName'],
        maps[i]['pCode'],
        maps[i]['name'],
        maps[i]['markedAsFavorite'],
        maps[i]['quantity'],
        maps[i]['qtySold'],
        maps[i]['qtyRefunded'],
        maps[i]['buyingPrice'],
        maps[i]['unitBp'],
        maps[i]['unitSellingPrice'],
        maps[i]['lowStockNotifierLimit'],
        maps[i]['supplierName'],
        maps[i]['supplierContacts'],
        maps[i]['dateAdded'],
        maps[i]['lastModified'],
        maps[i]['isSynced'],
        maps[i]['syncAction'],
      );
    });
  }

  /// -- defines a function to update an inventory item --
  Future<int> updateInventoryItem(CInventoryModel invItem, int pID) async {
    try {
      // Update the given inventory item.
      var updateResult = await _db!.update(invTable, invItem.toMap(),

          // ensure that the inventory item has a matching product id.
          where: 'productId = ?',

          // pass the item's pCode as a whereArg to prevent SQL injection
          whereArgs: [pID]);
      return updateResult;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap!',
          message: e.toString(),
        );
      }

      return 0;
    }
  }

  /// -- delete inventory item --
  Future<int> deleteInventoryItem(CInventoryModel inventory) async {
    int result = await _db!.delete(
      'inventory',
      where: 'productId = ?',
      whereArgs: [inventory.productId],
    );

    return result;
  }

  /// -- update inventory upon sale --
  Future<int> updateStockCountAndSale(
      int newStockCount, int newTotalSales, int pId) async {
    try {
      int updateResult = await _db!.rawUpdate(
        '''
          UPDATE $invTable
          SET quantity = ?, qtySold = ?
          WHERE productId = ?
        ''',
        [newStockCount, newTotalSales, pId],
      );
      return updateResult;
    } catch (e) {
      return CPopupSnackBar.errorSnackBar(
        title: 'error updating stock count',
        message: e.toString(),
      );
    }
  }

  /// -- update inventory upon sale --
  Future<int> updateInvOfflineSyncAfterStockUpdate(
      String sAction, int pId) async {
    try {
      int updateResult = await _db!.rawUpdate(
        '''
          UPDATE $invTable
          SET syncAction = ?
          WHERE productId = ?
        ''',
        [sAction, pId],
      );
      // CPopupSnackBar.customToast(
      //   message: updateResult.toString(),
      //   forInternetConnectivityStatus: false,
      // );
      return updateResult;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'stock count sync error!',
          message: 'error updating stock count SYNC ACTION: $e',
        );
      }
      return 0;
    }
  }

  /// -- fetch all deletionForSyncItems --
  Future<List<CInvDelsModel>> fetchAllInvDels() async {
    // get a reference to the database.
    final db = _db;

    // raw query
    final dels = await db!.rawQuery(
        'SELECT * FROM $invDelsForSyncTable where syncAction = ? and itemCategory = ?',
        ['delete', 'inventory']);

    if (dels.isEmpty) {
      //CPopupSnackBar.customToast(message: 'IS EMPTY');
      return [];
    } else {
      final result =
          dels.map((json) => CInvDelsModel.fromMapObject(json)).toList();

      return result;
    }
  }

  Future<void> saveInvDelsForSync(CInvDelsModel delItem) async {
    try {
      // get a reference to the local database.
      final db = _db;
      await db!.insert(
        invDelsForSyncTable,
        delItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error performing transaction',
        message: e.toString(),
      );
      throw e.toString();
    }
  }

  /// -- fetch all updatesForSyncItems --
  Future<List<CInvDelsModel>> fetchAllInvUpdates() async {
    // get a reference to the database.
    final db = _db;

    // raw query
    final forUpdates = await db!.rawQuery(
        'SELECT * FROM $invDelsForSyncTable where syncAction = ? and itemCategory = ?',
        ['update', 'inventory']);

    final result =
        forUpdates.map((json) => CInvDelsModel.fromMapObject(json)).toList();

    return result;
  }

  Future<int> updateDel(CInvDelsModel delItem) async {
    int delRes = await _db!.update(
      invDelsForSyncTable,
      delItem.toMap(),
      where: 'itemId = ?',
      whereArgs: [delItem.itemId],
    );

    return delRes;
  }

  /// -- fetch top sellers --
  Future<List<CInventoryModel>> fetchTopSellers(String email) async {
    try {
      // Get a reference to the database.
      final db = _db;

      final topSellers = await db!.rawQuery(
          'SELECT * FROM $invTable WHERE userEmail = ? AND qtySold >= 1 ORDER BY qtySold DESC LIMIT 10',
          [email]);

      // convert the List<Map<String, dynamic> into a List<CInventoryModel>.
      return topSellers
          .map((json) => CInventoryModel.fromMapObject(json))
          .toList();
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error fetching top sellers',
        message: '$e',
      );
      throw e.toString();
    }
  }

  /// ==== ### CRUD OPERATIONS ON SALES TABLE ### ====
  // -- save sale details to the database --
  Future addSoldItem(CTxnsModel soldItem) async {
    try {
      // Get a reference to the database.
      final db = _db;
      // Insert the Note into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same Inventory item is inserted twice.
      //
      // In this case, replace any previous data.
      await db?.insert(txnsTable, soldItem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      saleItemAddedToDb.value = true;
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error performing transaction',
        message: e.toString(),
      );
      saleItemAddedToDb.value = false;
    }
  }

  /// -- fetch sold items --
  Future<List<CTxnsModel>> fetchAllSoldItems(String email) async {
    final db = _db;

    final transactions = await db!.rawQuery(
        'SELECT * from $txnsTable where userEmail = ? ORDER BY soldItemId DESC',
        [email]);

    // Convert the List<Map<String, dynamic> into a List<Note>.
    return transactions.map((json) => CTxnsModel.fromMapObject(json)).toList();
  }

  /// -- fetch transactions --
  Future<List<CTxnsModel>> fetchSoldItemsGroupedByTxnId(String email) async {
    final db = _db;

    final transactions = await db!.rawQuery(
        'SELECT * from $txnsTable where userEmail = ? GROUP BY txnId ORDER BY lastModified DESC',
        [email]);

    // Convert the List<Map<String, dynamic> into a List<Note>.
    return transactions.map((json) => CTxnsModel.fromMapObject(json)).toList();
  }

  /// -- defines a function to update a receipt/sold item --
  Future<int> updateReceiptItem(CTxnsModel receiptItem, int soldItemId) async {
    try {
      // Update the given receipt item.
      var updateResult = await _db!.update(txnsTable, receiptItem.toMap(),

          // ensure that the receipt item has a matching product id.
          where: 'soldItemId = ?',

          // pass the item's pCode as a whereArg to prevent SQL injection
          whereArgs: [soldItemId]);
      return updateResult;
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'Oh Snap! error updating receipt item',
        message: e.toString(),
      );
      return 0;
    }
  }

  /// -- defines a function to update a transaction's details --
  Future<int> updateTxnDetails(CTxnsModel txn, int txnId) async {
    try {
      var txnUpdateResult = await _db!.update(txnsTable, txn.toMap(),
          where: 'txnId = ?', whereArgs: [txnId]);

      return txnUpdateResult;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap! error updating txn details!',
          message: e.toString(),
        );
      }

      return 0;
    }
  }

  Future<int> updateTxnItemsSyncStatus(
      int syncStatus, String sAction, int soldItemId) async {
    try {
      // Get a reference to the database.
      final db = _db;

      int updateResult = await db!.rawUpdate(
        '''
          UPDATE $txnsTable 
          SET isSynced = ?, syncAction = ? 
          WHERE soldItemId = ?
        ''',
        [syncStatus, sAction, soldItemId],
      );

      // if (kDebugMode) {
      //   CPopupSnackBar.customToast(
      //     message: '$updateResult',
      //     forInternetConnectivityStatus: false,
      //   );
      // }

      return updateResult;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'txn sync error!',
          message: 'error updating txns SYNC LOCALLY: $e',
        );
      }

      throw e.toString();
    }
  }

  /// -- update data on txns table after a refund --
}
