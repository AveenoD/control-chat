// Versioned legal documents shown at signup and in Settings.
//
// Bump the version string whenever the text materially changes — existing users
// are then re-prompted for consent (the gate checks the user's accepted version
// against the current one). Versions are date-stamped for easy auditing.
//
// NOTE: This is template content, NOT legal advice. Have a lawyer review before
// a production launch (esp. India IT Rules 2021 intermediary obligations).

export const TOS_VERSION = "2026-06-30";
export const PRIVACY_VERSION = "2026-06-30";

export interface LegalDocument {
  type: "tos" | "privacy";
  version: string;
  title: string;
  updated: string;
  content: string;
}

const TOS_CONTENT = `Last updated: 30 June 2026

Welcome to AuraTalk. By creating an account or using the app, you agree to these Terms of Service ("Terms"). Please read them carefully.

1. Eligibility
You must be at least 13 years old (or the minimum age of digital consent in your country) to use AuraTalk. By using the app you confirm that you meet this requirement.

2. Your Account
You are responsible for activity on your account and for keeping your device secure. You agree to provide accurate information and to not impersonate others.

3. Acceptable Use
You agree NOT to use AuraTalk to:
- send unlawful, threatening, abusive, harassing, defamatory, or hateful content;
- share content that infringes others' intellectual property or privacy;
- distribute malware, spam, or engage in phishing or fraud;
- exploit, endanger, or share sexual content involving minors;
- violate any applicable law or regulation.

4. End-to-End Encryption
Messages, media, and calls are end-to-end encrypted. This means we cannot read your message content. You are solely responsible for the content you send and receive.

5. Content and Conduct
AuraTalk does not pre-screen content. However, we may suspend or terminate accounts that we reasonably believe violate these Terms or applicable law, including in response to valid legal requests.

6. Service Availability
AuraTalk is provided "as is" and "as available". We do not guarantee uninterrupted or error-free service and may modify or discontinue features at any time.

7. Limitation of Liability
To the maximum extent permitted by law, AuraTalk and its operators are not liable for any indirect, incidental, or consequential damages arising from your use of the app.

8. Termination
You may stop using AuraTalk at any time. We may suspend or terminate access if you breach these Terms.

9. Changes to these Terms
We may update these Terms from time to time. When we make material changes, we will ask you to review and accept the updated Terms before continuing to use the app.

10. Governing Law
These Terms are governed by the laws of India. Disputes are subject to the exclusive jurisdiction of the competent courts.

11. Contact
For questions about these Terms, contact support through the app.`;

const PRIVACY_CONTENT = `Last updated: 30 June 2026

Your privacy is central to AuraTalk. This Privacy Policy explains what we collect, how we use it, and the choices you have.

1. Information We Collect
- Account data: your phone number (used to verify your account), username, and display name.
- Device data: a device identifier and public encryption keys needed to deliver messages.
- Technical data: limited logs (e.g. timestamps, connection metadata) to operate and secure the service.

2. What We CANNOT See
Your messages, media, files, and calls are end-to-end encrypted. We do not have the keys to read or listen to your conversations. Encrypted media is stored only as ciphertext.

3. How We Use Information
- to create and secure your account;
- to deliver messages and route calls between devices;
- to prevent abuse, fraud, and to comply with the law.

4. Sharing
We do not sell your personal data. We use trusted infrastructure providers (e.g. encrypted object storage) solely to operate the service. We may disclose limited account information if required by a valid legal request.

5. Data Retention
Encrypted message envelopes are retained only as long as needed for delivery and sync. Account information is retained while your account is active. You may delete your account, after which we remove your account data subject to legal retention requirements.

6. Your Rights
Depending on your jurisdiction, you may have rights to access, correct, or delete your personal data. You can manage your profile and privacy settings in the app.

7. Security
We use end-to-end encryption and encryption-at-rest on your device. No system is perfectly secure, so we encourage you to keep your device protected.

8. Children's Privacy
AuraTalk is not directed at children under the minimum age of digital consent. We do not knowingly collect data from such users.

9. Changes to this Policy
We may update this Policy. When we make material changes, we will ask you to review and accept the updated Policy before continuing to use the app.

10. Contact
For privacy questions or requests, contact support through the app.`;

export const LEGAL_DOCUMENTS: Record<"tos" | "privacy", LegalDocument> = {
  tos: {
    type: "tos",
    version: TOS_VERSION,
    title: "Terms of Service",
    updated: "30 June 2026",
    content: TOS_CONTENT
  },
  privacy: {
    type: "privacy",
    version: PRIVACY_VERSION,
    title: "Privacy Policy",
    updated: "30 June 2026",
    content: PRIVACY_CONTENT
  }
};
