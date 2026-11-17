/**
 * TravelPulse LK — Authentication Controller (Nisal)
 * Handles commuter sign in, registration, and authenticated user profile.
 */

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { userRepository } = require('../repositories');

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.trim() === '') {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('CRITICAL: JWT_SECRET environment variable is missing in production mode!');
    }
    return 'travelpulse_development_jwt_secret_key_2026';
  }
  return secret;
}

function createToken(user) {
  const payload = {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
  };
  return jwt.sign(payload, getJwtSecret(), {
    expiresIn: process.env.JWT_EXPIRES_IN || '24h',
  });
}

async function login(req, res) {
  try {
    const { emailOrUsername, password } = req.body || {};

    if (!emailOrUsername || !password) {
      return res.status(400).json({
        success: false,
        statusCode: 400,
        message: 'Both email/username and password are required.',
        error: { code: 'VALIDATION_ERROR' },
      });
    }

    const user = await userRepository.findUserByEmail(emailOrUsername);

    if (!user || !user.password_hash || !bcrypt.compareSync(password, user.password_hash)) {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: 'Invalid email or password. Please verify your credentials.',
        error: { code: 'INVALID_CREDENTIALS' },
      });
    }

    const token = createToken(user);
    const { password: _p, password_hash: _ph, ...safeUser } = user;

    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: 'Authentication successful.',
      data: {
        token,
        user: safeUser,
      },
    });
  } catch (err) {
    console.error('[AuthController.login] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Authentication failed due to internal error.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function register(req, res) {
  try {
    const { name, email, password, phoneNumber } = req.body || {};

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

    // Enforce role = 'commuter'; never trust client-supplied role
    const result = await userRepository.createUser({
      name: name.trim(),
      email: email.trim(),
      password,
      phoneNumber: phoneNumber ? phoneNumber.trim() : null,
      role: 'commuter',
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
  } catch (err) {
    console.error('[AuthController.register] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Registration failed due to internal error.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function getMe(req, res) {
  try {
    const userId = req.user && req.user.id;
    const user = await userRepository.findUserById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        statusCode: 404,
        message: 'User profile not found.',
        error: { code: 'USER_NOT_FOUND' },
      });
    }

    const rep = await userRepository.getUserReputation(userId);

    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: 'User profile retrieved successfully.',
      data: {
        ...user,
        reputation: rep || null,
      },
    });
  } catch (err) {
    console.error('[AuthController.getMe] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to retrieve user profile.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

module.exports = {
  login,
  register,
  getMe,
  createToken,
  getJwtSecret,
};
