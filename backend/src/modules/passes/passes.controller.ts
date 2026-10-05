import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { PassService } from '../../services/pass.service.js';

const scanPayloadSchema = z.object({
  qrPayload: z.string().min(1),
  scannerStaffId: z.string().default('hostess_gate_1'),
  gateLocation: z.string().default('Main Entry Gate A'),
});

// In-memory checked-in passes store (mirrored to PostgreSQL in production)
const checkedInPasses = new Set<string>();

export class PassesController {
  private passService = PassService.getInstance();

  /**
   * POST /api/v1/passes/verify-gate-scan
   * Hostess gate scanning endpoint to admit attendees
   */
  public verifyGateScan = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = scanPayloadSchema.parse(req.body);

      // 1. Verify QR structure and cryptographic HMAC signature
      const result = this.passService.validateQrPayload(data.qrPayload);
      if (!result.valid || !result.passNumber) {
        return res.status(400).json({
          success: false,
          admitted: false,
          reason: result.message,
        });
      }

      // 2. Prevent duplicate entry (already scanned passes)
      if (checkedInPasses.has(result.passNumber)) {
        return res.status(409).json({
          success: false,
          admitted: false,
          passNumber: result.passNumber,
          reason: 'ALREADY_USED: This pass has already been scanned for entry!',
        });
      }

      // 3. Mark pass as checked-in
      checkedInPasses.add(result.passNumber);

      return res.status(200).json({
        success: true,
        admitted: true,
        message: 'PASS VERIFIED: Attendee Admitted',
        data: {
          passNumber: result.passNumber,
          guestCount: result.guestCount,
          amountPaid: result.amount,
          paymentId: result.paymentId,
          gate: data.gateLocation,
          scannedBy: data.scannerStaffId,
          checkInTime: new Date().toISOString(),
        },
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /api/v1/passes/:passNumber
   * Retrieve status of a pass
   */
  public getPassStatus = async (req: Request, res: Response) => {
    const passNumber = String(req.params.passNumber);
    const isUsed = checkedInPasses.has(passNumber);

    return res.status(200).json({
      success: true,
      data: {
        passNumber,
        status: isUsed ? 'CHECKED_IN' : 'ACTIVE',
        isUsed,
      },
    });
  };
}
