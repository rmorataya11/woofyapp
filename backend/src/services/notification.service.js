import { transporter } from '../config/email';
import logger from '../utils/logger';
const sendReminderEmail = async (userEmail, reminderData) => {
  try {
    if (!transporter) {
      logger.warn('Transporter de email no configurado');
      return { success: false, message: 'Email no configurado' };
    }

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: userEmail,
      subject: `Recordatorio: ${reminderData.title}`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f5f5f5;">
          <div style="background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #4CAF50;">WooFy - Recordatorio</h2>
            <h3 style="color: #333;">${reminderData.title}</h3>
            <p style="color: #666; font-size: 16px; line-height: 1.6;">
              ${reminderData.description || 'No hay descripción adicional'}
            </p>
            <div style="background-color: #f0f7ff; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <p style="margin: 0; color: #333;">
                <strong>Mascota:</strong> ${reminderData.petName}<br>
                <strong>Fecha:</strong> ${new Date(reminderData.due_at).toLocaleString('es-ES', {
                  dateStyle: 'full',
                  timeStyle: 'short'
                })}
              </p>
            </div>
            <p style="color: #888; font-size: 14px;">
              Este es un recordatorio automático de WooFy App.
            </p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    logger.info(`Email de recordatorio enviado a ${userEmail}`);
    
    return { success: true, message: 'Email enviado correctamente' };
  } catch (error) {
    logger.error('Error al enviar email de recordatorio:', error);
    return { success: false, message: 'Error al enviar email' };
  }
};

const sendAppointmentConfirmationEmail = async (userEmail, appointmentData) => {
  try {
    if (!transporter) {
      logger.warn('Transporter de email no configurado');
      return { success: false, message: 'Email no configurado' };
    }

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: userEmail,
      subject: `Confirmación de Cita - ${appointmentData.clinicName}`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f5f5f5;">
          <div style="background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #2196F3;">Confirmación de Cita</h2>
            <p style="color: #666; font-size: 16px;">
              Tu cita ha sido confirmada exitosamente.
            </p>
            <div style="background-color: #e3f2fd; padding: 20px; border-radius: 5px; margin: 20px 0;">
              <p style="margin: 5px 0; color: #333;">
                <strong>Clínica:</strong> ${appointmentData.clinicName}<br>
                <strong>Servicio:</strong> ${appointmentData.serviceName}<br>
                <strong>Mascota:</strong> ${appointmentData.petName}<br>
                <strong>Fecha:</strong> ${new Date(appointmentData.starts_at).toLocaleString('es-ES', {
                  dateStyle: 'full',
                  timeStyle: 'short'
                })}<br>
                ${appointmentData.notes ? `<strong>Notas:</strong> ${appointmentData.notes}` : ''}
              </p>
            </div>
            <p style="color: #888; font-size: 14px;">
              ¡No olvides llevar la cartilla de vacunación de tu mascota!
            </p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    logger.info(`Email de confirmación enviado a ${userEmail}`);
    
    return { success: true, message: 'Email enviado correctamente' };
  } catch (error) {
    logger.error('Error al enviar email de confirmación:', error);
    return { success: false, message: 'Error al enviar email' };
  }
};

const sendWelcomeEmail = async (userEmail, userName) => {
  try {
    if (!transporter) {
      logger.warn('Transporter de email no configurado');
      return { success: false, message: 'Email no configurado' };
    }

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: userEmail,
      subject: '¡Bienvenido a WooFy!',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f5f5f5;">
          <div style="background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #4CAF50;">¡Bienvenido a WooFy!</h2>
            <p style="color: #666; font-size: 16px; line-height: 1.6;">
              Hola ${userName || 'amigo perruno'},
            </p>
            <p style="color: #666; font-size: 16px; line-height: 1.6;">
              Gracias por unirte a WooFy, tu app de gestión de mascotas. 
              Ahora podrás llevar un registro completo del cuidado de tus mascotas, 
              agendar citas veterinarias y recibir recordatorios importantes.
            </p>
            <div style="text-align: center; margin: 30px 0;">
              <p style="font-size: 18px; color: #333;">¡Empieza agregando tu primera mascota!</p>
            </div>
            <p style="color: #888; font-size: 14px; text-align: center;">
              Si tienes alguna pregunta, no dudes en contactarnos.
            </p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    logger.info(`Email de bienvenida enviado a ${userEmail}`);
    
    return { success: true, message: 'Email enviado correctamente' };
  } catch (error) {
    logger.error('Error al enviar email de bienvenida:', error);
    return { success: false, message: 'Error al enviar email' };
  }
};

export {
  sendReminderEmail,
  sendAppointmentConfirmationEmail,
  sendWelcomeEmail
};

