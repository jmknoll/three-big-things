require 'net/http'
require 'json'

class ResendMailer
  API_URL = "https://api.resend.com/emails"

  def self.send_confirmation(user)
    base_url = ENV.fetch('APP_BASE_URL', 'http://localhost:8080')
    url = "#{base_url}/confirm_email?token=#{user.confirmation_token}"
    send_email(
      to: user.email,
      subject: "Confirm your Evensong account",
      html: confirmation_html(url)
    )
  end

  def self.send_password_reset(user)
    base_url = ENV.fetch('APP_BASE_URL', 'http://localhost:8080')
    url = "#{base_url}/reset_password?token=#{user.reset_password_token}"
    send_email(
      to: user.email,
      subject: "Reset your Evensong password",
      html: password_reset_html(url)
    )
  end

  # Returns true on success, false on failure or when API key is absent (dev).
  def self.send_email(to:, subject:, html:)
    api_key = ENV['RESEND_API_KEY']
    unless api_key
      Rails.logger.info "[ResendMailer] No RESEND_API_KEY — skipping send to #{to} (#{subject})"
      return true
    end

    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri.path)
    req['Authorization'] = "Bearer #{api_key}"
    req['Content-Type']  = 'application/json'
    req.body = {
      from: ENV.fetch('RESEND_FROM_EMAIL', 'Evensong <noreply@evensong.jamesonknoll.com>'),
      to: [to],
      subject: subject,
      html: html
    }.to_json

    res = http.request(req)
    success = res.code.to_i < 300
    Rails.logger.warn "[ResendMailer] Failed (#{res.code}): #{res.body}" unless success
    success
  rescue => e
    Rails.logger.error "[ResendMailer] Error: #{e.message}"
    false
  end

  # ---------------------------------------------------------------------------
  # Email HTML templates
  # ---------------------------------------------------------------------------

  def self.confirmation_html(url)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif; background: #F2F2F7; margin: 0; padding: 40px 16px; }
          .container { max-width: 480px; margin: 0 auto; background: white; border-radius: 14px; padding: 40px 32px; }
          h1 { color: #1C1C1E; font-size: 22px; font-weight: 600; margin: 0 0 8px; }
          p { color: #6C6C70; font-size: 15px; line-height: 1.5; margin: 0 0 24px; }
          .button { display: inline-block; background: #4CAF7D; color: white; text-decoration: none; padding: 12px 24px; border-radius: 10px; font-size: 15px; font-weight: 600; }
          .footer { color: #AEAEB2; font-size: 13px; margin-top: 32px; padding-top: 24px; border-top: 1px solid #E5E5EA; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Confirm your email</h1>
          <p>Tap the button below to verify your email address and activate your Evensong account.</p>
          <a href="#{url}" class="button">Confirm email</a>
          <p class="footer">This link expires in 48 hours. If you didn't create an account, you can ignore this email.</p>
        </div>
      </body>
      </html>
    HTML
  end

  def self.password_reset_html(url)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif; background: #F2F2F7; margin: 0; padding: 40px 16px; }
          .container { max-width: 480px; margin: 0 auto; background: white; border-radius: 14px; padding: 40px 32px; }
          h1 { color: #1C1C1E; font-size: 22px; font-weight: 600; margin: 0 0 8px; }
          p { color: #6C6C70; font-size: 15px; line-height: 1.5; margin: 0 0 24px; }
          .button { display: inline-block; background: #4CAF7D; color: white; text-decoration: none; padding: 12px 24px; border-radius: 10px; font-size: 15px; font-weight: 600; }
          .footer { color: #AEAEB2; font-size: 13px; margin-top: 32px; padding-top: 24px; border-top: 1px solid #E5E5EA; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Reset your password</h1>
          <p>We received a request to reset your Evensong password. Tap the button below to choose a new one.</p>
          <a href="#{url}" class="button">Reset password</a>
          <p class="footer">This link expires in 1 hour. If you didn't request a password reset, you can ignore this email.</p>
        </div>
      </body>
      </html>
    HTML
  end
end
