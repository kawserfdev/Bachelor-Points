const admin = require('firebase-admin');

let initError = null;

// Parse the service account from environment variable
if (!admin.apps.length) {
  try {
    const rawInput = process.env.FIREBASE_SERVICE_ACCOUNT;
    if (!rawInput) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is missing.');
    }
    
    let serviceAccountJson = rawInput.trim();
    
    // Check if the input is a raw JSON string or Base64 encoded
    if (!serviceAccountJson.startsWith('{')) {
      try {
        serviceAccountJson = Buffer.from(serviceAccountJson, 'base64').toString('utf-8');
      } catch (e) {
        throw new Error('Failed to decode Base64 FIREBASE_SERVICE_ACCOUNT: ' + e.message);
      }
    }

    let serviceAccount;
    try {
      serviceAccount = JSON.parse(serviceAccountJson);
    } catch (e) {
      throw new Error('Failed to parse service account JSON: ' + e.message);
    }

    // Validate the service account keys
    const requiredKeys = ['project_id', 'private_key', 'client_email'];
    const missingKeys = requiredKeys.filter(key => !serviceAccount[key]);
    if (missingKeys.length > 0) {
      const details = [];
      if (serviceAccount.projectId || serviceAccount.project_info || serviceAccount.apiKey) {
        details.push('It looks like a Firebase Client Config (google-services.json / firebase_options) was provided instead of a Service Account Private Key.');
      }
      throw new Error(
        `Invalid Service Account JSON. Missing required properties: ${missingKeys.join(', ')}. ` +
        (details.length ? details.join(' ') : 'Please generate a new private key from Firebase Console -> Project Settings -> Service Accounts.')
      );
    }

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error);
    initError = error;
  }
}


export default async function handler(req, res) {
  // Check initialization status
  if (initError || !admin.apps.length) {
    return res.status(500).json({ 
      error: 'Firebase Admin SDK failed to initialize.', 
      details: initError ? initError.message : 'No initialized apps found.' 
    });
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  // Basic security check (Optional: verify API key)
  const apiKey = req.headers['x-api-key'];
  if (process.env.API_SECRET_KEY && apiKey !== process.env.API_SECRET_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { targetUserId, title, body, type, route } = req.body;

  if (!targetUserId || !title || !body) {
    return res.status(400).json({ error: 'Missing required fields: targetUserId, title, or body.' });
  }

  try {
    // Fetch tokens for the user from Firestore
    const tokensSnapshot = await admin.firestore()
      .collection('users')
      .doc(targetUserId)
      .collection('fcm_tokens')
      .get();

    if (tokensSnapshot.empty) {
      return res.status(404).json({ error: 'No FCM tokens found for the user.' });
    }

    const tokens = tokensSnapshot.docs.map(doc => doc.data().token);

    // Prepare the message payload
    const message = {
      notification: {
        title,
        body
      },
      data: {
        type: type || 'general',
        route: route || '/'
      },
      tokens: tokens
    };

    // Send the push notification using Firebase Admin
    const response = await admin.messaging().sendEachForMulticast(message);
    
    return res.status(200).json({ 
      success: true, 
      message: 'Notification sent successfully',
      successCount: response.successCount,
      failureCount: response.failureCount
    });

  } catch (error) {
    console.error('Error sending notification:', error);
    return res.status(500).json({ error: 'Internal Server Error', details: error.message });
  }
}
