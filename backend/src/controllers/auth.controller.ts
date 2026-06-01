import type { NextFunction, Request, Response } from "express";
import { sendError, sendNoContent, sendOne } from "../lib/response";
import { authRepo } from "../repositories/auth.repo";
import { authService } from "../services/auth.service";
import { subscriptionService } from "../services/subscription.service";

export const authController = {
  register: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tokens = await authService.register(req.body);
      res.status(201).json({ data: tokens });
    } catch (err) {
      next(err);
    }
  },

  login: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tokens = await authService.login(req.body);
      res.json({ data: tokens });
    } catch (err) {
      next(err);
    }
  },

  refresh: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tokens = await authService.refresh(req.body.refreshToken);
      res.json({ data: tokens });
    } catch (err) {
      next(err);
    }
  },

  logout: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const refreshToken = req.body.refreshToken ?? "";
      await authService.logout(refreshToken, req.auth?.jti);
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  me: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { sub, subType, farmId } = req.auth;
      const farmOwnerId = subType === "owner" ? sub : farmId;

      if (subType === "staff") {
        const staff = await authRepo.findStaffById(sub);
        if (!staff) return sendError(res, 404, "NOT_FOUND", "User not found");
        const { passwordHash: _pw, ...safe } = staff;
        const modules = await subscriptionService.getModulesForFarm(farmOwnerId);
        const subscription = await subscriptionService.getPlan(farmOwnerId);
        const owner = await authRepo.findOwnerById(farmOwnerId);
        sendOne(res, {
          ...safe,
          farmName: owner?.farmName ?? "",
          country: owner?.country ?? "",
          province: owner?.province ?? "",
          subscriptionPlan: subscription?.planId ?? "starter",
          subscriptionStatus: subscription?.status ?? "trial",
          activatedModules: modules,
          trialEndsAt: subscription?.endDate ?? null,
          mfaEnabled: false,
        });
      } else {
        const owner = await authRepo.findOwnerById(sub);
        if (!owner) return sendError(res, 404, "NOT_FOUND", "User not found");
        const { passwordHash: _pw, ...safe } = owner;
        const modules = await subscriptionService.getModulesForFarm(sub);
        const subscription = await subscriptionService.getPlan(sub);
        sendOne(res, {
          ...safe,
          farmName: safe.farmName ?? "",
          country: safe.country ?? "",
          province: safe.province ?? "",
          subscriptionPlan: subscription?.planId ?? "starter",
          subscriptionStatus: subscription?.status ?? "trial",
          activatedModules: modules,
          trialEndsAt: subscription?.endDate ?? null,
          mfaEnabled: false,
          role: "superAdmin",
          farmOwnerId: null,
        });
      }
    } catch (err) {
      next(err);
    }
  },

  forgotPassword: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await authService.forgotPassword(req.body.email);
      res.json({
        data: { message: "If the email exists, a reset link has been sent." },
      });
    } catch (err) {
      next(err);
    }
  },

  resetPassword: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await authService.resetPassword(req.body.token, req.body.password);
      res.json({ data: { message: "Password reset successful." } });
    } catch (err) {
      next(err);
    }
  },

  verifyEmail: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await authService.verifyEmail(req.query["token"] as string);
      res.json({ data: { message: "Email verified." } });
    } catch (err) {
      next(err);
    }
  },

  acceptInvite: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tokens = await authService.acceptInvite(req.body);
      res.status(201).json({ data: tokens });
    } catch (err) {
      next(err);
    }
  },

  changePassword: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { sub, subType } = req.auth;
      await authService.changePassword(sub, subType, req.body.currentPassword, req.body.newPassword);
      res.json({ data: { message: "Password changed successfully." } });
    } catch (err) {
      next(err);
    }
  },

  updateProfile: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { sub, subType } = req.auth;
      const profile = await authService.updateProfile(sub, subType, req.body);
      sendOne(res, profile);
    } catch (err) {
      next(err);
    }
  },

  socialLogin: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await authService.socialLogin(req.body);
      res.json({ data: result });
    } catch (err) {
      next(err);
    }
  },
};
