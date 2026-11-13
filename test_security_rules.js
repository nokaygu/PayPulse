// PayPulse Firestore Security Rules Verification Test Suite
// Executes against live Firebase Firestore Emulator (JDK 21)

const host = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
const BASE_URL = `http://${host}/v1/projects/paypulse-fd869/databases/(default)/documents`;

console.log('===============================================================');
console.log('  PayPulse Firebase Security Rules Test Suite');
console.log('  Target Host:', host);
console.log('===============================================================\n');

function authHeader(uid) {
  if (!uid) return {};
  if (uid === 'admin_master') return { 'Authorization': 'Bearer owner' };
  
  const header = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify({
    user_id: uid,
    sub: uid,
    aud: 'paypulse-fd869',
    iss: 'https://securetoken.google.com/paypulse-fd869',
    auth_time: Math.floor(Date.now() / 1000)
  })).toString('base64url');
  
  return { 'Authorization': `Bearer ${header}.${payload}.` };
}

async function api(method, path, body, uid) {
  const url = `${BASE_URL}${path}`;
  const res = await fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...authHeader(uid)
    },
    body: body ? JSON.stringify(body) : undefined
  });
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch (e) { json = text; }
  return { status: res.status, ok: res.ok, data: json };
}

async function commit(writes, uid) {
  return await api('POST', ':commit', { writes }, uid);
}

// Convert simple JS object to Firestore REST fields format
function toFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === null) fields[k] = { nullValue: null };
    else if (typeof v === 'boolean') fields[k] = { booleanValue: v };
    else if (typeof v === 'number') {
      if (Number.isInteger(v)) fields[k] = { integerValue: v.toString() };
      else fields[k] = { doubleValue: v };
    }
    else if (typeof v === 'string') {
      if (v === 'SERVER_TIMESTAMP') fields[k] = { timestampValue: new Date().toISOString() };
      else fields[k] = { stringValue: v };
    }
    else if (Array.isArray(v)) {
      fields[k] = { arrayValue: { values: v.map(item => ({ stringValue: item })) } };
    }
  }
  return fields;
}

let testCount = 0;
let passedCount = 0;

function assertTest(name, isSuccess, details) {
  testCount++;
  if (isSuccess) {
    passedCount++;
    console.log(`[PASS] ${testCount}. ${name}`);
  } else {
    console.error(`[FAIL] ${testCount}. ${name} -> Details:`, details);
  }
}

async function runTests() {
  const nowIso = new Date().toISOString();

  // 0. Seed Initial Documents as admin (bypassing rules)
  console.log('Seeding initial documents with admin bypass...');
  
  // Seed Users
  await api('PATCH', '/users/user_employee?updateMask.fieldPaths=uid&updateMask.fieldPaths=name&updateMask.fieldPaths=email&updateMask.fieldPaths=role&updateMask.fieldPaths=companyId&updateMask.fieldPaths=hasB2BAccess', {
    fields: toFields({
      uid: 'user_employee',
      name: 'Abdullah Belli',
      email: 'belliabdullah@gmail.com',
      role: 'employee',
      companyId: 'company_001',
      hasB2BAccess: true
    })
  }, 'admin_master');

  await api('PATCH', '/users/user_admin?updateMask.fieldPaths=uid&updateMask.fieldPaths=name&updateMask.fieldPaths=email&updateMask.fieldPaths=role&updateMask.fieldPaths=companyId&updateMask.fieldPaths=hasB2BAccess', {
    fields: toFields({
      uid: 'user_admin',
      name: 'Yonetici Abdullah',
      email: 'abdullahbelli.dev@gmail.com',
      role: 'admin',
      companyId: 'company_001',
      hasB2BAccess: true
    })
  }, 'admin_master');

  // Seed Company
  await api('PATCH', '/companies/company_001?updateMask.fieldPaths=companyId&updateMask.fieldPaths=name&updateMask.fieldPaths=adminIds', {
    fields: toFields({
      companyId: 'company_001',
      name: 'Nova Tasarım A.Ş.',
      adminIds: ['user_admin']
    })
  }, 'admin_master');

  // Seed Wallets
  await api('PATCH', '/wallets/wallet_user_employee?updateMask.fieldPaths=walletId&updateMask.fieldPaths=ownerId&updateMask.fieldPaths=balanceTl&updateMask.fieldPaths=balanceUsd&updateMask.fieldPaths=balanceEur&updateMask.fieldPaths=iban&updateMask.fieldPaths=lastTxId&updateMask.fieldPaths=updatedAt', {
    fields: toFields({
      walletId: 'wallet_user_employee',
      ownerId: 'user_employee',
      balanceTl: 500000,
      balanceUsd: 50000,
      balanceEur: 30000,
      iban: 'TR450099900000000000000001',
      lastTxId: 'tx_init',
      updatedAt: nowIso
    })
  }, 'admin_master');

  await api('PATCH', '/wallets/wallet_user_admin?updateMask.fieldPaths=walletId&updateMask.fieldPaths=ownerId&updateMask.fieldPaths=balanceTl&updateMask.fieldPaths=balanceUsd&updateMask.fieldPaths=balanceEur&updateMask.fieldPaths=iban&updateMask.fieldPaths=lastTxId&updateMask.fieldPaths=updatedAt', {
    fields: toFields({
      walletId: 'wallet_user_admin',
      ownerId: 'user_admin',
      balanceTl: 1000000,
      balanceUsd: 100000,
      balanceEur: 50000,
      iban: 'TR180099900000000000000002',
      lastTxId: 'tx_init',
      updatedAt: nowIso
    })
  }, 'admin_master');

  await api('PATCH', '/wallets/wallet_company_001?updateMask.fieldPaths=walletId&updateMask.fieldPaths=ownerId&updateMask.fieldPaths=balanceTl&updateMask.fieldPaths=balanceUsd&updateMask.fieldPaths=balanceEur&updateMask.fieldPaths=iban&updateMask.fieldPaths=lastTxId&updateMask.fieldPaths=updatedAt', {
    fields: toFields({
      walletId: 'wallet_company_001',
      ownerId: 'company_001',
      balanceTl: 5000000,
      balanceUsd: 0,
      balanceEur: 0,
      iban: 'TR880099900000000000000003',
      lastTxId: 'tx_init',
      updatedAt: nowIso
    })
  }, 'admin_master');

  console.log('Seeding completed. Beginning Security Rule Tests...\n');

  // TEST 6: Yetkisiz kullanıcı başka cüzdanı okuyamıyor
  {
    const readOther = await api('GET', '/wallets/wallet_user_admin', null, 'user_employee');
    assertTest('Yetkisiz kullanıcı başka cüzdanı okuyamıyor (403)', readOther.status === 403, readOther.data);
  }

  // TEST 1: Geçerli FAST transferi başarılı (Atomik commit)
  const txFast1 = 'tx_fast_test_001';
  {
    const res = await commit([
      // Sender wallet update (-10000 kurus = 100 TL)
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fields: toFields({
            walletId: 'wallet_user_employee',
            ownerId: 'user_employee',
            balanceTl: 490000,
            balanceUsd: 50000,
            balanceEur: 30000,
            iban: 'TR450099900000000000000001',
            lastTxId: txFast1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] },
        currentDocument: { exists: true }
      },
      // Server timestamp for sender wallet
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Receiver wallet update (+10000 kurus)
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_admin`,
          fields: toFields({
            walletId: 'wallet_user_admin',
            ownerId: 'user_admin',
            balanceTl: 1010000,
            balanceUsd: 100000,
            balanceEur: 50000,
            iban: 'TR180099900000000000000002',
            lastTxId: txFast1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] },
        currentDocument: { exists: true }
      },
      // Server timestamp for receiver wallet
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_admin`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Transaction document creation
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/transactions/${txFast1}`,
          fields: toFields({
            txId: txFast1,
            senderId: 'user_employee',
            receiverId: 'user_admin',
            amount: 10000,
            currency: 'TRY',
            timestamp: new Date().toISOString(),
            type: 'fast',
            status: 'Başarılı'
          })
        }
      }
    ], 'user_employee');

    assertTest('Geçerli FAST transferi başarılı', res.ok, res.data);
  }

  // TEST 2: Bakiye düşmeden para ekleme reddediliyor
  {
    const txHack = 'tx_hack_free_money';
    const res = await commit([
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fields: toFields({
            walletId: 'wallet_user_employee',
            ownerId: 'user_employee',
            balanceTl: 9999999, // Artış var ama gönderen cüzdanı yok
            balanceUsd: 50000,
            balanceEur: 30000,
            iban: 'TR450099900000000000000001',
            lastTxId: txHack
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      }
    ], 'user_employee');
    assertTest('Bakiye düşmeden para ekleme reddediliyor (403)', !res.ok, res.data);
  }

  // TEST 3: İşlem tutarından fazla bakiye ekleme reddediliyor
  {
    const txFraud = 'tx_fraud_amount';
    const res = await commit([
      // Sender: -1000 kurus
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fields: toFields({
            walletId: 'wallet_user_employee',
            ownerId: 'user_employee',
            balanceTl: 489000,
            balanceUsd: 50000,
            balanceEur: 30000,
            iban: 'TR450099900000000000000001',
            lastTxId: txFraud,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Receiver tries to gain 50000 kurus while tx is 1000 kurus!
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_admin`,
          fields: toFields({
            walletId: 'wallet_user_admin',
            ownerId: 'user_admin',
            balanceTl: 1060000,
            balanceUsd: 100000,
            balanceEur: 50000,
            iban: 'TR180099900000000000000002',
            lastTxId: txFraud,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_admin`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/transactions/${txFraud}`,
          fields: toFields({
            txId: txFraud,
            senderId: 'user_employee',
            receiverId: 'user_admin',
            amount: 1000,
            currency: 'TRY',
            timestamp: new Date().toISOString(),
            type: 'fast',
            status: 'Başarılı'
          })
        }
      }
    ], 'user_employee');
    assertTest('İşlem tutarından fazla bakiye ekleme reddediliyor (403)', !res.ok, res.data);
  }

  // TEST 4: Eski txId tekrar kullanımı reddediliyor
  {
    // Replay txFast1
    const res = await commit([
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fields: toFields({
            walletId: 'wallet_user_employee',
            ownerId: 'user_employee',
            balanceTl: 480000,
            balanceUsd: 50000,
            balanceEur: 30000,
            iban: 'TR450099900000000000000001',
            lastTxId: txFast1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      }
    ], 'user_employee');
    assertTest('Eski txId tekrar kullanımı reddediliyor (403)', !res.ok, res.data);
  }

  // TEST 5: Sahte transaction kaydı (başkası adına) reddediliyor
  {
    const res = await api('PATCH', '/transactions/tx_fake_001', {
      fields: toFields({
        txId: 'tx_fake_001',
        senderId: 'user_admin', // Employee attempts to sign as admin
        receiverId: 'user_employee',
        amount: 50000,
        currency: 'TRY',
        timestamp: new Date().toISOString(),
        type: 'fast',
        status: 'Başarılı'
      })
    }, 'user_employee');
    assertTest('Sahte transaction kaydı reddediliyor (403)', !res.ok, res.data);
  }

  // TEST 7: Yetkisiz masraf onayı reddediliyor
  {
    // Employee tries to create an expense first
    await api('PATCH', '/expenses/exp_test_001', {
      fields: toFields({
        expenseId: 'exp_test_001',
        employeeId: 'user_employee',
        employeeName: 'Abdullah Belli',
        merchantTitle: 'Opet Yakıt',
        category: 'Ulaşım',
        companyId: 'company_001',
        amount: 50000,
        vatAmount: 10000,
        receiptImageUrl: '/local/receipt.jpg',
        status: 'pending',
        date: new Date().toISOString(),
        accountingCode: '770.01'
      })
    }, 'user_employee');

    // Employee tries to approve their own expense
    const res = await api('PATCH', '/expenses/exp_test_001?updateMask.fieldPaths=status', {
      fields: toFields({ status: 'approved' })
    }, 'user_employee');
    assertTest('Yetkisiz masraf onayı reddediliyor (403)', !res.ok, res.data);
  }

  // TEST 8: Geçerli masraf onayı şirket kasasından düşüp çalışana ekliyor
  const txExp1 = 'tx_exp_approve_001';
  {
    const res = await commit([
      // Company wallet: -50000 kurus (5000000 -> 4950000)
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_company_001`,
          fields: toFields({
            walletId: 'wallet_company_001',
            ownerId: 'company_001',
            balanceTl: 4950000,
            balanceUsd: 0,
            balanceEur: 0,
            iban: 'TR880099900000000000000003',
            lastTxId: txExp1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_company_001`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Employee wallet: +50000 kurus (490000 -> 540000)
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fields: toFields({
            walletId: 'wallet_user_employee',
            ownerId: 'user_employee',
            balanceTl: 540000,
            balanceUsd: 50000,
            balanceEur: 30000,
            iban: 'TR450099900000000000000001',
            lastTxId: txExp1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Expense record updated to approved
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/expenses/exp_test_001`,
          fields: toFields({
            status: 'approved',
            approvedBy: 'user_admin',
            accountingCode: '770.01',
            txId: txExp1
          })
        },
        updateMask: { fieldPaths: ['status', 'approvedAt', 'approvedBy', 'accountingCode', 'txId'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/expenses/exp_test_001`,
          fieldTransforms: [{ fieldPath: 'approvedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Transaction record
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/transactions/${txExp1}`,
          fields: toFields({
            txId: txExp1,
            senderId: 'company_001',
            receiverId: 'user_employee',
            amount: 50000,
            currency: 'TRY',
            timestamp: new Date().toISOString(),
            type: 'expense_reimbursement',
            relatedId: 'exp_test_001',
            status: 'Başarılı'
          })
        }
      }
    ], 'user_admin');

    assertTest('Geçerli masraf onayı şirket kasasından düşüp çalışana ekliyor', res.ok, res.data);
  }

  // TEST 9: Mükerrer masraf onayı reddediliyor
  {
    const txExpDup = 'tx_exp_dup_002';
    const res = await commit([
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/expenses/exp_test_001`,
          fields: toFields({
            status: 'approved',
            approvedBy: 'user_admin',
            accountingCode: '770.01',
            txId: txExpDup
          })
        },
        updateMask: { fieldPaths: ['status', 'approvedAt', 'approvedBy', 'accountingCode', 'txId'] }
      }
    ], 'user_admin');
    assertTest('Mükerrer masraf onayı reddediliyor (403)', !res.ok, res.data);
  }

  // TEST 10: Ödeme yapılmadan payment request completed olamıyor
  {
    // Admin creates payment request
    await api('PATCH', '/payment_requests/req_test_001', {
      fields: toFields({
        requestId: 'req_test_001',
        merchantId: 'company_001',
        amount: 25000,
        currency: 'TRY',
        status: 'pending',
        description: 'Web Tasarım Hizmet Bedeli'
      })
    }, 'user_admin');

    // Trying to complete payment request without atomic wallet transfer
    const res = await api('PATCH', '/payment_requests/req_test_001?updateMask.fieldPaths=status&updateMask.fieldPaths=payerId', {
      fields: toFields({
        status: 'completed',
        payerId: 'user_employee'
      })
    }, 'user_employee');
    assertTest('Ödeme yapılmadan payment request completed olamıyor (403)', !res.ok, res.data);
  }

  // TEST 11: Sahte relatedId ile bildirim oluşturulamıyor
  {
    const res = await api('PATCH', '/notifications/notif_fake_999', {
      fields: toFields({
        notificationId: 'notif_fake_999',
        userId: 'user_employee',
        title: 'Sahte Bildirim',
        body: 'Sahte bildirim metni',
        type: 'transfer_received',
        relatedId: 'fake_tx_id_does_not_exist',
        isRead: false,
        createdAt: 'SERVER_TIMESTAMP'
      })
    }, 'user_admin');
    assertTest('Sahte relatedId ile bildirim oluşturulamıyor (403)', !res.ok, res.data);
  }

  // TEST 12: Geçerli finansal bildirim oluşturulabiliyor (Gerçek tx ile)
  {
    const res = await api('PATCH', `/notifications/notif_tx_${txFast1}`, {
      fields: toFields({
        notificationId: `notif_tx_${txFast1}`,
        userId: 'user_admin', // The receiver of txFast1
        title: 'Para Transferi Alındı',
        body: 'Yeni FAST transferiniz var. İşlem geçmişini kontrol edin.',
        type: 'transfer_received',
        relatedId: txFast1,
        isRead: false,
        createdAt: 'SERVER_TIMESTAMP'
      })
    }, 'user_employee'); // Sent by the sender of txFast1
    assertTest('Geçerli finansal bildirim oluşturulabiliyor', res.ok, res.data);
  }

  // TEST 13: QR cüzdan ödemesi başarılı
  const txQr1 = 'tx_qr_pos_001';
  {
    const res = await commit([
      // Payer wallet: -20000 kurus (540000 -> 520000)
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fields: toFields({
            walletId: 'wallet_user_employee',
            ownerId: 'user_employee',
            balanceTl: 520000,
            balanceUsd: 50000,
            balanceEur: 30000,
            iban: 'TR450099900000000000000001',
            lastTxId: txQr1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_user_employee`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Company wallet: +20000 kurus (4950000 -> 4970000)
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_company_001`,
          fields: toFields({
            walletId: 'wallet_company_001',
            ownerId: 'company_001',
            balanceTl: 4970000,
            balanceUsd: 0,
            balanceEur: 0,
            iban: 'TR880099900000000000000003',
            lastTxId: txQr1,
          })
        },
        updateMask: { fieldPaths: ['balanceTl', 'balanceUsd', 'balanceEur', 'lastTxId', 'updatedAt'] }
      },
      {
        transform: {
          document: `projects/paypulse-fd869/databases/(default)/documents/wallets/wallet_company_001`,
          fieldTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]
        }
      },
      // Transaction document
      {
        update: {
          name: `projects/paypulse-fd869/databases/(default)/documents/transactions/${txQr1}`,
          fields: toFields({
            txId: txQr1,
            senderId: 'user_employee',
            receiverId: 'company_001',
            amount: 20000,
            currency: 'TRY',
            timestamp: new Date().toISOString(),
            type: 'qr_pos_payment',
            status: 'Başarılı'
          })
        }
      }
    ], 'user_employee');
    assertTest('QR cüzdan ödemesi başarılı', res.ok, res.data);
  }

  // TEST 14: Yeni B2C kayıt ve cüzdan oluşturma başarılı
  {
    const newUid = 'user_new_b2c_99';
    const newIban = 'TR990099900000000000000099';

    // 1. Create B2C user profile
    const userRes = await api('PATCH', `/users/${newUid}`, {
      fields: toFields({
        uid: newUid,
        name: 'Yeni Müşteri',
        email: 'yeni@paypulse.com',
        role: 'b2c',
        hasB2BAccess: false
      })
    }, newUid);

    // 2. Create zero-balance wallet
    const walletRes = await api('PATCH', `/wallets/wallet_${newUid}`, {
      fields: toFields({
        walletId: `wallet_${newUid}`,
        ownerId: newUid,
        balanceTl: 0,
        balanceUsd: 0,
        balanceEur: 0,
        iban: newIban
      })
    }, newUid);

    assertTest('Yeni B2C kayıt ve cüzdan oluşturma başarılı', userRes.ok && walletRes.ok, { user: userRes.data, wallet: walletRes.data });
  }

  console.log('\n===============================================================');
  console.log(`  Test Results: ${passedCount} / ${testCount} PASSED (${Math.round((passedCount/testCount)*100)}%)`);
  console.log('===============================================================\n');

  if (passedCount !== testCount) {
    process.exit(1);
  }
}

runTests().catch(err => {
  console.error('Fatal error during test run:', err);
  process.exit(1);
});
