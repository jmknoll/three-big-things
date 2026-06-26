class PasswordResetsController < ApplicationController
  def new
    token = params[:token].to_s
    user  = User.find_by(reset_password_token: token)

    if user&.password_reset_token_valid?
      render plain: form_html(token: token), content_type: 'text/html'
    else
      render plain: invalid_html, content_type: 'text/html', status: :unprocessable_entity
    end
  end

  def create
    token    = params[:token].to_s
    password = params[:password].to_s
    confirm  = params[:password_confirmation].to_s
    user     = User.find_by(reset_password_token: token)

    unless user&.password_reset_token_valid?
      render plain: invalid_html, content_type: 'text/html', status: :unprocessable_entity
      return
    end

    if password.length < 6
      render plain: form_html(token: token, error: "Password must be at least 6 characters."),
             content_type: 'text/html', status: :unprocessable_entity
      return
    end

    if password != confirm
      render plain: form_html(token: token, error: "Passwords don't match."),
             content_type: 'text/html', status: :unprocessable_entity
      return
    end

    user.password = password
    if user.save(validate: false)
      user.clear_password_reset_token!
      user.confirm_email! unless user.email_confirmed?
      render plain: success_html, content_type: 'text/html'
    else
      render plain: form_html(token: token, error: "Could not update password. Please try again."),
             content_type: 'text/html', status: :unprocessable_entity
    end
  end

  private

  def form_html(token:, error: nil)
    error_markup = error ? "<p class=\"error\">#{error}</p>" : ""
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Reset password — Evensong</title>
        <style>
          *, *::before, *::after { box-sizing: border-box; }
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
                 background: #F2F2F7; display: flex; align-items: center;
                 justify-content: center; min-height: 100vh; margin: 0; padding: 16px; }
          .card { background: #fff; border-radius: 14px; padding: 40px 32px;
                  max-width: 380px; width: 100%; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
          h1  { color: #1C1C1E; font-size: 22px; font-weight: 600; margin: 0 0 8px; }
          p   { color: #6C6C70; font-size: 15px; line-height: 1.5; margin: 0 0 24px; }
          label { display: block; color: #3A3A3C; font-size: 13px; font-weight: 500;
                  margin-bottom: 6px; }
          input[type=password] {
            width: 100%; padding: 12px 14px; border: 1px solid #E5E5EA;
            border-radius: 10px; font-size: 15px; color: #1C1C1E;
            background: #fff; outline: none; margin-bottom: 14px;
          }
          input[type=password]:focus { border-color: rgba(94,106,210,0.5); }
          button { width: 100%; padding: 13px; background: #4CAF7D; color: #fff;
                   border: none; border-radius: 10px; font-size: 15px;
                   font-weight: 600; cursor: pointer; margin-top: 4px; }
          .error { color: #D4845A; font-size: 14px; margin: -8px 0 16px; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>New password</h1>
          <p>Choose a password at least 6 characters long.</p>
          #{error_markup}
          <form method="POST" action="/reset_password">
            <input type="hidden" name="token" value="#{token}">
            <label for="password">New password</label>
            <input type="password" id="password" name="password"
                   minlength="6" autocomplete="new-password" required>
            <label for="password_confirmation">Confirm password</label>
            <input type="password" id="password_confirmation"
                   name="password_confirmation" minlength="6"
                   autocomplete="new-password" required>
            <button type="submit">Set new password</button>
          </form>
        </div>
      </body>
      </html>
    HTML
  end

  def success_html
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Password updated — Evensong</title>
        <style>
          *, *::before, *::after { box-sizing: border-box; }
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
                 background: #F2F2F7; display: flex; align-items: center;
                 justify-content: center; min-height: 100vh; margin: 0; padding: 16px; }
          .card { background: #fff; border-radius: 14px; padding: 40px 32px;
                  max-width: 380px; width: 100%; text-align: center;
                  box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
          .icon { font-size: 32px; color: #4CAF7D; margin-bottom: 16px; }
          h1 { color: #1C1C1E; font-size: 22px; font-weight: 600; margin: 0 0 8px; }
          p  { color: #6C6C70; font-size: 15px; line-height: 1.5; margin: 0; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">✓</div>
          <h1>Password updated</h1>
          <p>Your password has been changed. You can return to the app and sign in.</p>
        </div>
      </body>
      </html>
    HTML
  end

  def invalid_html
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Link expired — Evensong</title>
        <style>
          *, *::before, *::after { box-sizing: border-box; }
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
                 background: #F2F2F7; display: flex; align-items: center;
                 justify-content: center; min-height: 100vh; margin: 0; padding: 16px; }
          .card { background: #fff; border-radius: 14px; padding: 40px 32px;
                  max-width: 380px; width: 100%; text-align: center;
                  box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
          .icon { font-size: 32px; color: #D4845A; margin-bottom: 16px; }
          h1 { color: #1C1C1E; font-size: 22px; font-weight: 600; margin: 0 0 8px; }
          p  { color: #6C6C70; font-size: 15px; line-height: 1.5; margin: 0; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">✕</div>
          <h1>Link expired</h1>
          <p>This link has expired or is invalid. Request a new one from the app.</p>
        </div>
      </body>
      </html>
    HTML
  end
end
