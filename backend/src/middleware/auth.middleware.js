/**
 * TravelPulse LK — Authentication & Authorization Middleware
 * Integrates with Nisal's JWT authentication framework.
 */

const jwt = require('jsonwebtoken');
const { userRepository } = require('../repositories');

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.trim() === '') {
    if (process.env.NODE_ENV === 'production') {
      return null;
    }
    return 'travelpulse_development_jwt_secret_key_2026';
  }
  return secret;
}

async function parseToken(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7).trim();
  if (!token) return null;

  // 1. Support for known test tokens used in development & tests ONLY.
  // STRICT SECURITY REQUIREMENT: Never accepted when NODE_ENV === 'production'.
  if (process.env.NODE_ENV !== 'production') {
    if (token === 'test-token-kamal' || token === 'kamal-jwt-token') {
      return { id: 1, name: 'Kamal Perera', email: 'kamal@example.com', role: 'commuter' };
    }
    if (token === 'test-token-dilshan' || token === 'dilshan-jwt-token') {
      return { id: 2, name: 'Dilshan Silva', email: 'dilshan@example.com', role: 'commuter' };
    }
    if (token === 'test-token-moderator' || token === 'moderator-jwt-token') {
      return { id: 99, name: 'Transit Moderator', email: 'moderator@travelpulse.lk', role: 'moderator' };
    }
    if (token === 'test-token-admin') {
      return { id: 100, name: 'System Admin', email: 'admin@travelpulse.lk', role: 'admin' };
    }
  }

  // 2. Cryptographic JWT verification using jsonwebtoken
  const secret = getJwtSecret();
  if (!secret) {
    return null;
  }

  try {
    const decoded = jwt.verify(token, secret);
    const userId = decoded.id || decoded.userId || decoded.sub;

    // Validate account against persistent user repository to enforce server-authoritative role
    const dbUser = await userRepository.findUserById(userId);
    if (dbUser) {
      return {
        id: dbUser.id,
        name: dbUser.name,
        email: dbUser.email,
        role: dbUser.role, // Server-verified role, never trusting forged tokens
      };
    }

    return {
      id: userId,
      name: decoded.name || 'Commuter',
      email: decoded.email || '',
      role: decoded.role || 'commuter',
    };
  } catch (err) {
    // Malformed, expired, invalid signature, or tampered token
    return null;
  }
}

/**
 * Require valid authenticated session
 */
async function requireAuth(req, res, next) {
  try {
    const user = await parseToken(req.headers.authorization);

    if (!user || !user.id) {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: 'Authentication required. Please provide a valid Bearer token.',
        error: {
          code: 'UNAUTHORIZED',
          details: 'Missing, expired, or invalid Authorization token.',
        },
      });
    }

    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      statusCode: 401,
      message: 'Authentication required. Please provide a valid Bearer token.',
      error: { code: 'UNAUTHORIZED' },
    });
  }
}

/**
 * Optional authentication: populates req.user if token is present, otherwise leaves null
 */
async function optionalAuth(req, res, next) {
  try {
    const user = await parseToken(req.headers.authorization);
    req.user = user || null;
    next();
  } catch (err) {
    req.user = null;
    next();
  }
}

/**
 * Require specific role(s) (e.g. 'moderator', 'admin')
 */
function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: 'Authentication required.',
        error: { code: 'UNAUTHORIZED' },
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        statusCode: 403,
        message: 'Forbidden. Insufficient role permissions.',
        error: { code: 'INSUFFICIENT_ROLE' },
      });
    }

    next();
  };
}

module.exports = {
  requireAuth,
  optionalAuth,
  requireRole,
  parseToken,
};
