import { env } from "../config/env";

export interface SocialProfile {
  email: string;
  firstName: string;
  lastName: string;
  emailVerified: boolean;
  providerId: string;
}

/**
 * Verifies a social provider ID token and extracts the user profile.
 * Each provider has its own verification mechanism.
 */
export const socialVerifier = {
  /**
   * Verify a Google ID token via Google's tokeninfo endpoint.
   * In production, use google-auth-library for offline verification.
   */
  async verifyGoogle(idToken: string): Promise<SocialProfile> {
    const response = await fetch(
      `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`,
    );
    if (!response.ok) {
      throw Object.assign(new Error("Invalid Google token"), {
        status: 401,
        code: "INVALID_SOCIAL_TOKEN",
      });
    }
    const payload = (await response.json()) as Record<string, string>;

    // Verify audience matches our client ID
    const clientId = env.GOOGLE_CLIENT_ID;
    if (clientId && payload["aud"] !== clientId) {
      throw Object.assign(new Error("Google token audience mismatch"), {
        status: 401,
        code: "INVALID_SOCIAL_TOKEN",
      });
    }

    return {
      email: payload["email"]!,
      firstName: payload["given_name"] ?? "",
      lastName: payload["family_name"] ?? "",
      emailVerified: payload["email_verified"] === "true",
      providerId: payload["sub"]!,
    };
  },

  /**
   * Verify an Apple ID token (JWT signed by Apple's JWKS).
   * Uses jose library for JWKS-based verification.
   */
  async verifyApple(idToken: string): Promise<SocialProfile> {
    const { createRemoteJWKSet, jwtVerify } = await import("jose");
    const APPLE_JWKS = createRemoteJWKSet(
      new URL("https://appleid.apple.com/auth/keys"),
    );

    const { payload } = await jwtVerify(idToken, APPLE_JWKS, {
      issuer: "https://appleid.apple.com",
      audience: env.APPLE_CLIENT_ID || undefined,
    }).catch(() => {
      throw Object.assign(new Error("Invalid Apple token"), {
        status: 401,
        code: "INVALID_SOCIAL_TOKEN",
      });
    });

    const claims = payload as Record<string, unknown>;
    const email = claims["email"] as string;
    // Apple may not send name after first login — handle gracefully
    const name = (claims["name"] as Record<string, string>) ?? {};

    return {
      email,
      firstName: name["firstName"] ?? "",
      lastName: name["lastName"] ?? "",
      emailVerified: (claims["email_verified"] as boolean) ?? false,
      providerId: claims["sub"] as string,
    };
  },

  /**
   * Verify a Facebook access token via the Graph API debug_token endpoint.
   */
  async verifyFacebook(idToken: string): Promise<SocialProfile> {
    const appId = env.FACEBOOK_APP_ID;
    const appSecret = env.FACEBOOK_APP_SECRET;

    if (!appId || !appSecret) {
      throw Object.assign(new Error("Facebook auth not configured"), {
        status: 501,
        code: "SOCIAL_NOT_CONFIGURED",
      });
    }

    // Verify the token is valid
    const debugResp = await fetch(
      `https://graph.facebook.com/debug_token?input_token=${encodeURIComponent(idToken)}&access_token=${appId}|${appSecret}`,
    );
    if (!debugResp.ok) {
      throw Object.assign(new Error("Invalid Facebook token"), {
        status: 401,
        code: "INVALID_SOCIAL_TOKEN",
      });
    }
    const debugData = (await debugResp.json()) as { data: Record<string, unknown> };
    if (!debugData.data["is_valid"]) {
      throw Object.assign(new Error("Facebook token is not valid"), {
        status: 401,
        code: "INVALID_SOCIAL_TOKEN",
      });
    }

    // Fetch user profile
    const profileResp = await fetch(
      `https://graph.facebook.com/me?fields=id,email,first_name,last_name&access_token=${encodeURIComponent(idToken)}`,
    );
    if (!profileResp.ok) {
      throw Object.assign(new Error("Failed to fetch Facebook profile"), {
        status: 401,
        code: "INVALID_SOCIAL_TOKEN",
      });
    }
    const profile = (await profileResp.json()) as Record<string, string>;

    return {
      email: profile["email"]!,
      firstName: profile["first_name"] ?? "",
      lastName: profile["last_name"] ?? "",
      emailVerified: true, // Facebook requires verified email
      providerId: profile["id"]!,
    };
  },
};
