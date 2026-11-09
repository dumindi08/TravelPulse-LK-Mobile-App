/**
 * TravelPulse LK — Authentication Controller (Nisal)
 * Handles commuter sign in, registration, and authenticated user profile.
 */

const { memoryStore } = require('../config/db');

function createToken(user) {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64');
  const payload = Buffer.from(
    JSON.stringify({
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 86400,
    })
  ).toString('base64');
  const signature = Buffer.from('travelpulse_signature_verification').toString('base64');
  return `${header}.${payload}.${signature}`;
}

async function login(req, res) {
  const { emailOrUsername, password } = req.body || {};

  if (!emailOrUsername || !password) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Both email/username and password are required.',
      error: { code: 'VALIDATION_ERROR' },
    });
  }

  const user = memoryStore.findUserByEmail(emailOrUsername);

  if (!user || user.password !== password) {
    return res.status(401).json({
      success: false,
      statusCode: 401,
      message: 'Invalid email or password. Please verify your credentials.',
      error: { code: 'INVALID_CREDENTIALS' },
    });
  }

  const token = createToken(user);
  const { password: _, ...safeUser } = user;

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Authentication successful.',
    data: {
      token,
      user: safeUser,
    },
  });
}

async function register(req, res) {
  const { name, email, password, phoneNumber, role } = req.body || {};

  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Name, email, and password are required for registration.',
      error: { code: 'VALIDATION_ERROR' },
    });
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Please provide a valid email address.',
      error: { code: 'INVALID_EMAIL' },
    });
  }

  if (password.length < 8) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Password must be at least 8 characters long.',
      error: { code: 'WEAK_PASSWORD' },
    });
  }

  const result = memoryStore.createUser({
    name,
    email,
    password,
    phoneNumber,
    role: role || 'commuter',
  });

  if (result.error) {
    return res.status(409).json({
      success: false,
      statusCode: 409,
      message: result.message,
      error: { code: result.error },
    });
  }

  const token = createToken(result);

  return res.status(201).json({
    success: true,
    statusCode: 201,
    message: 'User account created successfully.',
    data: {
      token,
      user: result,
    },
  });
}

async function getMe(req, res) {
  const userId = req.user && req.user.id;
  const user = memoryStore.findUserById(userId);

  if (!user) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: 'User profile not found.',
      error: { code: 'USER_NOT_FOUND' },
    });
  }

  const rep = memoryStore.getUserReputation(userId);

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'User profile retrieved successfully.',
    data: {
      ...user,
      reputation: rep || null,
    },
  });
}

module.exports = {
  login,
  register,
  getMe,
};

