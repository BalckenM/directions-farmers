import type { NextFunction, Request, Response } from "express";
import { sendError, sendNoContent, sendOne } from "../lib/response";
import { authRepo } from "../repositories/auth.repo";
import { authService } from "../services/auth.service";

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
      await authService.logout(refreshToken);
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  me: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const owner = await authRepo.findOwnerById(req.auth.sub);
      if (!owner) return sendError(res, 404, "NOT_FOUND", "User not found");
      const { passwordHash: _pw, ...safe } = owner;
      sendOne(res, safe);
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
};
