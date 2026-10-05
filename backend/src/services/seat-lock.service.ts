import Redis from 'ioredis';
import { config } from '../config/env.js';

export interface LockResult {
  success: boolean;
  lockKey: string;
  lockedUntil: Date;
  message: string;
}

export class SeatLockService {
  private static instance: SeatLockService;
  private redisClient: Redis | null = null;
  private inMemoryLocks: Map<string, { userId: string; lockedUntil: number }> = new Map();

  private constructor() {
    // If REDIS_URL is provided, attempt connection without unhandled crashing
    if (process.env.REDIS_URL && !process.env.REDIS_URL.includes('disabled')) {
      try {
        this.redisClient = new Redis(config.redis.url, {
          maxRetriesPerRequest: 0,
          retryStrategy: () => null, // Stop reconnecting if server is down
          enableOfflineQueue: false,
          lazyConnect: true,
        });

        this.redisClient.on('error', () => {
          // Suppress unhandled redis connection errors for graceful in-memory fallback
          this.redisClient = null;
        });

        this.redisClient.connect().catch(() => {
          this.redisClient = null;
        });
      } catch {
        this.redisClient = null;
      }
    }
  }

  public static getInstance(): SeatLockService {
    if (!SeatLockService.instance) {
      SeatLockService.instance = new SeatLockService();
    }
    return SeatLockService.instance;
  }

  /**
   * Acquire a lock on a concert seat, table slot, or tour slot for 10 minutes.
   */
  public async acquireLock(
    eventId: string,
    slotKey: string,
    userId: string,
    ttlSeconds = config.redis.seatLockTtlSeconds
  ): Promise<LockResult> {
    const lockKey = `lock:${eventId}:${slotKey}`;
    const now = Date.now();
    const lockedUntil = new Date(now + ttlSeconds * 1000);

    // 1. Try via Redis
    if (this.redisClient) {
      try {
        const acquired = await this.redisClient.set(lockKey, userId, 'EX', ttlSeconds, 'NX');
        if (acquired === 'OK') {
          return {
            success: true,
            lockKey,
            lockedUntil,
            message: `Slot locked for ${ttlSeconds / 60} minutes`,
          };
        }
        return {
          success: false,
          lockKey,
          lockedUntil: new Date(),
          message: 'Selected slot is currently on hold by another customer. Please choose another or try in a few minutes.',
        };
      } catch {
        // Fall back to in-memory if Redis error occurs
      }
    }

    // 2. In-Memory fallback
    this.cleanupExpiredMemoryLocks();
    const existing = this.inMemoryLocks.get(lockKey);
    if (existing && existing.lockedUntil > now && existing.userId !== userId) {
      return {
        success: false,
        lockKey,
        lockedUntil: new Date(existing.lockedUntil),
        message: 'Selected slot is currently held by another customer.',
      };
    }

    this.inMemoryLocks.set(lockKey, { userId, lockedUntil: now + ttlSeconds * 1000 });
    return {
      success: true,
      lockKey,
      lockedUntil,
      message: `Slot reserved for checkout (${ttlSeconds / 60} mins)`,
    };
  }

  /**
   * Release lock when order is cancelled or expires
   */
  public async releaseLock(eventId: string, slotKey: string, userId: string): Promise<boolean> {
    const lockKey = `lock:${eventId}:${slotKey}`;

    if (this.redisClient) {
      try {
        const currentHolder = await this.redisClient.get(lockKey);
        if (currentHolder === userId) {
          await this.redisClient.del(lockKey);
          return true;
        }
      } catch {
        // Fall through
      }
    }

    const memoryLock = this.inMemoryLocks.get(lockKey);
    if (memoryLock && memoryLock.userId === userId) {
      this.inMemoryLocks.delete(lockKey);
      return true;
    }
    return false;
  }

  private cleanupExpiredMemoryLocks() {
    const now = Date.now();
    for (const [key, value] of this.inMemoryLocks.entries()) {
      if (value.lockedUntil <= now) {
        this.inMemoryLocks.delete(key);
      }
    }
  }
}
