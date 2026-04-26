const crypto = require("node:crypto");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const {onCall, HttpsError} = require("firebase-functions/v2/https");

admin.initializeApp();

const db = admin.firestore();

function getTransporter() {
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || "587");
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (!host || !user || !pass) {
    throw new HttpsError(
      "failed-precondition",
      "SMTP credentials are not configured for OTP delivery.",
    );
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: {
      user,
      pass,
    },
  });
}

function hashOtp(uid, otp) {
  return crypto.createHash("sha256").update(`${uid}:${otp}`).digest("hex");
}

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

exports.sendEmailOtp = onCall({cors: true}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  const email = String(request.data?.email || request.auth.token.email || "").trim();
  if (!email) {
    throw new HttpsError("invalid-argument", "A valid email is required.");
  }

  const otp = generateOtp();
  const uid = request.auth.uid;
  const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + 10 * 60 * 1000);
  const transporter = getTransporter();
  const fromAddress = process.env.SMTP_FROM || process.env.SMTP_USER;

  await transporter.sendMail({
    from: fromAddress,
    to: email,
    subject: "Your verification code",
    text: `Your verification code is ${otp}. It expires in 10 minutes.`,
    html: `<p>Your verification code is <strong>${otp}</strong>.</p><p>It expires in 10 minutes.</p>`,
  });

  await db.collection("email_otps").doc(uid).set({
    uid,
    email,
    codeHash: hashOtp(uid, otp),
    expiresAt,
    attempts: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {success: true};
});

exports.verifyEmailOtp = onCall({cors: true}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  const otp = String(request.data?.otp || "").trim();
  if (!/^\d{6}$/.test(otp)) {
    throw new HttpsError("invalid-argument", "OTP must be exactly 6 digits.");
  }

  const uid = request.auth.uid;
  const email = String(request.data?.email || request.auth.token.email || "").trim();
  const otpRef = db.collection("email_otps").doc(uid);
  const otpSnapshot = await otpRef.get();

  if (!otpSnapshot.exists) {
    throw new HttpsError("not-found", "No active OTP was found.");
  }

  const otpData = otpSnapshot.data();
  if (!otpData) {
    throw new HttpsError("not-found", "No active OTP was found.");
  }

  if (otpData.email !== email) {
    throw new HttpsError("permission-denied", "OTP email does not match the signed-in user.");
  }

  if (otpData.expiresAt.toMillis() < Date.now()) {
    await otpRef.delete();
    throw new HttpsError("deadline-exceeded", "The OTP has expired. Request a new code.");
  }

  if (otpData.attempts >= 5) {
    await otpRef.delete();
    throw new HttpsError("permission-denied", "Too many invalid attempts. Request a new code.");
  }

  const candidateHash = hashOtp(uid, otp);
  if (candidateHash !== otpData.codeHash) {
    await otpRef.update({
      attempts: admin.firestore.FieldValue.increment(1),
    });
    throw new HttpsError("invalid-argument", "The OTP you entered is incorrect.");
  }

  await db.collection("users").doc(uid).set({
    uid,
    email,
    isEmailVerified: true,
    verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  await otpRef.delete();

  return {success: true};
});

exports.verifyAdminPassword = onCall({cors: true}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  const adminEmail = "moza3@admin.com";
  const callerEmail = String(request.auth.token.email || "").trim().toLowerCase();
  if (!callerEmail || callerEmail !== adminEmail) {
    throw new HttpsError("permission-denied", "This account is not allowed to become admin.");
  }

  const secret = process.env.ADMIN_PASSWORD;
  if (!secret) {
    throw new HttpsError("failed-precondition", "ADMIN_PASSWORD is not configured.");
  }

  const password = String(request.data?.password || "");
  if (!password) {
    throw new HttpsError("invalid-argument", "Password is required.");
  }

  if (password !== secret) {
    throw new HttpsError("permission-denied", "Invalid admin password.");
  }

  await admin.auth().setCustomUserClaims(request.auth.uid, {admin: true});
  return {success: true};
});
