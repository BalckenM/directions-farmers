import nodemailer from "nodemailer";
import { env } from "../config/env";

const transport = nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: env.SMTP_PORT,
  secure: env.SMTP_PORT === 465,
  auth: { user: env.SMTP_USER, pass: env.SMTP_PASS },
});

export const emailService = {
  sendVerificationEmail: (to: string, token: string) =>
    transport.sendMail({
      from: `"4D Farmer" <${env.SMTP_USER}>`,
      to,
      subject: "Verify your email",
      html: `<p>Click <a href="${env.APP_URL}/verify-email?token=${token}">here</a> to verify your email. Link expires in 24 hours.</p>`,
    }),

  sendPasswordResetEmail: (to: string, token: string) =>
    transport.sendMail({
      from: `"4D Farmer" <${env.SMTP_USER}>`,
      to,
      subject: "Reset your password",
      html: `<p>Click <a href="${env.APP_URL}/reset-password?token=${token}">here</a> to reset your password. Link expires in 1 hour.</p>`,
    }),

  sendStaffInviteEmail: (to: string, token: string, farmName: string) =>
    transport.sendMail({
      from: `"4D Farmer" <${env.SMTP_USER}>`,
      to,
      subject: `You're invited to join ${farmName}`,
      html: `<p>Click <a href="${env.APP_URL}/accept-invite?token=${token}">here</a> to accept the invitation. Link expires in 7 days.</p>`,
    }),

  sendPayslipEmail: (to: string, name: string, pdfBuffer: Buffer) =>
    transport.sendMail({
      from: `"4D Farmer" <${env.SMTP_USER}>`,
      to,
      subject: "Your payslip",
      html: `<p>Dear ${name}, please find your payslip attached.</p>`,
      attachments: [{ filename: "payslip.pdf", content: pdfBuffer }],
    }),
};
