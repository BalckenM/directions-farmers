import { Router } from "express";
import { authController } from "../controllers/auth.controller";
import { authenticate } from "../middleware/auth.middleware";
import {
    authGeneralLimiter,
    authLoginLimiter,
} from "../middleware/rate-limiter.middleware";
import { validate } from "../middleware/validate.middleware";
import {
    acceptInviteSchema,
    changePasswordSchema,
    forgotPasswordSchema,
    loginSchema,
    refreshSchema,
    registerSchema,
    resetPasswordSchema,
    socialAuthSchema,
    updateProfileSchema,
} from "../validators/auth.validator";

export const authRouter = Router();

authRouter.post(
  "/register",
  authGeneralLimiter,
  validate(registerSchema),
  authController.register,
);
authRouter.post(
  "/login",
  authLoginLimiter,
  validate(loginSchema),
  authController.login,
);
authRouter.post(
  "/refresh",
  authGeneralLimiter,
  validate(refreshSchema),
  authController.refresh,
);
authRouter.post(
  "/logout",
  authenticate,
  authGeneralLimiter,
  authController.logout,
);
authRouter.get("/me", authenticate, authController.me);
authRouter.post(
  "/forgot-password",
  authLoginLimiter,
  validate(forgotPasswordSchema),
  authController.forgotPassword,
);
authRouter.post(
  "/reset-password",
  authGeneralLimiter,
  validate(resetPasswordSchema),
  authController.resetPassword,
);
authRouter.get("/verify-email", authController.verifyEmail);
authRouter.post(
  "/accept-invite",
  authGeneralLimiter,
  validate(acceptInviteSchema),
  authController.acceptInvite,
);
authRouter.put(
  "/change-password",
  authenticate,
  authGeneralLimiter,
  validate(changePasswordSchema),
  authController.changePassword,
);
authRouter.put(
  "/profile",
  authenticate,
  authGeneralLimiter,
  validate(updateProfileSchema),
  authController.updateProfile,
);
authRouter.post(
  "/social",
  authGeneralLimiter,
  validate(socialAuthSchema),
  authController.socialLogin,
);
