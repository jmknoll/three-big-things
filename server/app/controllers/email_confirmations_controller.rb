class EmailConfirmationsController < ApplicationController
  def confirm
    user = User.find_by(confirmation_token: params[:token])

    if user&.confirmation_token_valid?
      user.confirm_email!
      render plain: confirmed_html, content_type: 'text/html'
    else
      render plain: invalid_html(
        "This confirmation link has expired or is invalid.",
        "Request a new one from the app."
      ), content_type: 'text/html', status: :unprocessable_entity
    end
  end

  private

  def confirmed_html
    page_html(icon: "✓", icon_color: "#4CAF7D",
              title: "Email confirmed",
              body: "Your account is verified. You can return to the Evensong app.")
  end

  def invalid_html(title, body)
    page_html(icon: "✕", icon_color: "#D4845A", title: title, body: body)
  end

  def page_html(icon:, icon_color:, title:, body:)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{title} — Evensong</title>
        <style>
          *, *::before, *::after { box-sizing: border-box; }
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
                 background: #F2F2F7; display: flex; align-items: center;
                 justify-content: center; min-height: 100vh; margin: 0; padding: 16px; }
          .card { background: #fff; border-radius: 14px; padding: 40px 32px;
                  max-width: 380px; width: 100%; text-align: center;
                  box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
          .icon { font-size: 32px; font-weight: 600; color: #{icon_color};
                  margin-bottom: 16px; }
          h1 { color: #1C1C1E; font-size: 22px; font-weight: 600; margin: 0 0 8px; }
          p  { color: #6C6C70; font-size: 15px; line-height: 1.5; margin: 0; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">#{icon}</div>
          <h1>#{title}</h1>
          <p>#{body}</p>
        </div>
      </body>
      </html>
    HTML
  end
end
