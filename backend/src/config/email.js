import nodemailer from 'nodemailer';

const emailUser = process.env.EMAIL_USER;
const emailPass = process.env.EMAIL_PASS;

if (!emailUser || !emailPass) {
  console.warn('⚠️  Credenciales de email no configuradas. Las notificaciones por correo estarán deshabilitadas.');
}

const transporter = emailUser && emailPass 
  ? nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: emailUser,
        pass: emailPass
      }
    })
  : null;

export { transporter };

