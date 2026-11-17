/**
 * TravelPulse LK — User Repository (Module 1: Nisal)
 * Handles database operations for users, user profiles, and reputations.
 */

const bcrypt = require('bcryptjs');
const db = require('../config/db');

class UserRepository {
  /**
   * Find user by ID (safe: excludes password_hash)
   */
  async findUserById(id) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        'SELECT id, name, email, phone_number, role, is_active, created_at, updated_at FROM users WHERE id = ? AND is_active = TRUE',
        [id]
      );
      return rows && rows.length > 0 ? rows[0] : null;
    }
    db.assertFallbackAllowed();
    return db.memoryStore.findUserById(id);
  }

  /**
   * Find user by email or username (internal: includes password_hash for authentication)
   */
  async findUserByEmail(emailOrUsername) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        'SELECT id, name, email, password_hash, phone_number, role, is_active, created_at FROM users WHERE (email = ? OR name = ?) AND is_active = TRUE LIMIT 1',
        [emailOrUsername, emailOrUsername]
      );
      return rows && rows.length > 0 ? rows[0] : null;
    }
    db.assertFallbackAllowed();
    return db.memoryStore.findUserByEmail(emailOrUsername);
  }

  /**
   * Register a new user with bcrypt password hashing and default commuter role
   */
  async createUser({ name, email, password, phoneNumber, role = 'commuter' }) {
    const passwordHash = bcrypt.hashSync(password, 10);
    // Strict security rule: commuter role is server-enforced, never trusting client-supplied role
    const finalRole = 'commuter';

    if (db.isLiveDb) {
      const connection = await db.getConnection();
      try {
        await connection.beginTransaction();

        // 1. Check if email already exists
        const [existing] = await connection.query(
          'SELECT id FROM users WHERE email = ? LIMIT 1',
          [email]
        );
        if (existing && existing.length > 0) {
          await connection.rollback();
          return { error: 'EMAIL_ALREADY_EXISTS', message: 'An account with this email address already exists.' };
        }

        // 2. Insert into users
        const [insertResult] = await connection.query(
          'INSERT INTO users (name, email, password_hash, phone_number, role, is_active) VALUES (?, ?, ?, ?, ?, TRUE)',
          [name, email, passwordHash, phoneNumber || null, finalRole]
        );
        const newUserId = insertResult.insertId;

        // 3. Insert initial reputation score into user_reputations
        await connection.query(
          'INSERT INTO user_reputations (user_id, reputation_score, total_reports_submitted, verified_reports_count, rejected_reports_count, total_votes_cast) VALUES (?, 10.00, 0, 0, 0, 0)',
          [newUserId]
        );

        await connection.commit();

        return {
          id: newUserId,
          name,
          email,
          phoneNumber: phoneNumber || null,
          role: finalRole,
          isActive: true,
          createdAt: new Date().toISOString(),
        };
      } catch (err) {
        await connection.rollback();
        throw err;
      } finally {
        connection.release();
      }
    }

    db.assertFallbackAllowed();
    return db.memoryStore.createUser({ name, email, password, phoneNumber, role: finalRole });
  }

  /**
   * Get commuter trust reputation
   */
  async getUserReputation(userId) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        'SELECT user_id, reputation_score, total_reports_submitted, verified_reports_count, rejected_reports_count, total_votes_cast, updated_at FROM user_reputations WHERE user_id = ?',
        [userId]
      );
      if (rows && rows.length > 0) {
        return rows[0];
      }
      return {
        user_id: Number(userId),
        reputation_score: 10.0,
        total_reports_submitted: 0,
        verified_reports_count: 0,
        rejected_reports_count: 0,
        total_votes_cast: 0,
      };
    }
    db.assertFallbackAllowed();
    return db.memoryStore.getUserReputation(userId);
  }
}

module.exports = new UserRepository();

