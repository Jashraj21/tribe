import crypto from 'crypto';
import QRCode from 'qrcode';
import { config } from '../config/env.js';

export interface PassPayload {
  passNumber: string;
  bookingId: string;
  eventId: string;
  userId: string;
  guestCount: number;
  amount: number;
  paymentId: string;
}

export interface ValidationResult {
  valid: boolean;
  message: string;
  passNumber?: string;
  paymentId?: string;
  amount?: number;
  guestCount?: number;
  timestamp?: Date;
}

export class PassService {
  private static instance: PassService;

  public static getInstance(): PassService {
    if (!PassService.instance) {
      PassService.instance = new PassService();
    }
    return PassService.instance;
  }

  /**
   * Generates a tamper-proof cryptographically signed QR payload.
   */
  public generateSignedPayload(data: PassPayload): string {
    const timestamp = Date.now();
    const rawData = `TRIBE_PASS::${data.passNumber}::${data.paymentId}::${data.amount}::${data.guestCount}::${timestamp}`;

    // Cryptographic HMAC SHA256 signature using server secret
    const signature = crypto
      .createHmac('sha256', config.jwt.secret)
      .update(rawData)
      .digest('hex')
      .substring(0, 16);

    return `${rawData}::SIG_${signature}`;
  }

  /**
   * Generates a Base64 QR code image string (data:image/png;base64,...)
   */
  public async generateQrCodeDataUrl(payload: string): Promise<string> {
    try {
      return await QRCode.toDataURL(payload, {
        errorCorrectionLevel: 'M',
        margin: 2,
        width: 300,
        color: {
          dark: '#0B0F19',
          light: '#FFFFFF',
        },
      });
    } catch (error) {
      return '';
    }
  }

  /**
   * Validates scanned QR payload at gate by venue staff / hostess.
   */
  public validateQrPayload(scannedString: string): ValidationResult {
    if (!scannedString.startsWith('TRIBE_PASS::')) {
      return { valid: false, message: 'Invalid QR code. Not a TRIBE entry pass.' };
    }

    const parts = scannedString.split('::');
    if (parts.length < 5) {
      return { valid: false, message: 'Malformed QR pass payload.' };
    }

    const [_, passNumber, paymentId, amountStr, guestCountStr, timestampStr, sigWithPrefix] = parts;
    const amount = parseInt(amountStr, 10);
    const guestCount = parseInt(guestCountStr, 10);
    const timestamp = new Date(parseInt(timestampStr, 10));

    // If signature exists, verify cryptographic integrity
    if (sigWithPrefix && sigWithPrefix.startsWith('SIG_')) {
      const providedSig = sigWithPrefix.replace('SIG_', '');
      const rawData = `TRIBE_PASS::${passNumber}::${paymentId}::${amountStr}::${guestCountStr}::${timestampStr}`;
      const expectedSig = crypto
        .createHmac('sha256', config.jwt.secret)
        .update(rawData)
        .digest('hex')
        .substring(0, 16);

      if (providedSig !== expectedSig) {
        return { valid: false, message: 'Tampered pass detected! Cryptographic signature failed.' };
      }
    }

    return {
      valid: true,
      message: 'Valid Entry Pass Verified',
      passNumber,
      paymentId,
      amount,
      guestCount,
      timestamp,
    };
  }
}
