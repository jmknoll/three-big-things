class User < ApplicationRecord
  self.table_name = 'users'

  has_secure_password validations: false  # nil allowed for OAuth-only users

  has_many :goals, foreign_key: 'user_id'
  has_many :projects, foreign_key: :user_id, dependent: :destroy
  has_many :daily_goals, foreign_key: :user_id

  def recalculate_streak!
    today = Date.today

    if streak_last_calc_date == today
      return
    elsif streak_last_calc_date == today - 1
      yesterday_goals = daily_goals.where(date: streak_last_calc_date)
      if yesterday_goals.count >= 3 && yesterday_goals.where(status: ['complete', 'partial']).exists?
        self.meta_streak_current += 1
      else
        self.meta_streak_current = 0
      end
      self.meta_streak_longest = meta_streak_current if meta_streak_current > meta_streak_longest
    else
      self.meta_streak_current = 0
    end

    self.streak_last_calc_date = today
    save!
  end

  # ---------------------------------------------------------------------------
  # Email confirmation
  # ---------------------------------------------------------------------------

  def generate_confirmation_token!
    self.confirmation_token   = SecureRandom.urlsafe_base64(32)
    self.confirmation_sent_at = Time.current
    save!(validate: false)
  end

  def confirm_email!
    update_columns(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end

  def confirmation_token_valid?
    confirmation_sent_at.present? && confirmation_sent_at > 48.hours.ago
  end

  # ---------------------------------------------------------------------------
  # Password reset
  # ---------------------------------------------------------------------------

  def generate_password_reset_token!
    self.reset_password_token   = SecureRandom.urlsafe_base64(32)
    self.reset_password_sent_at = Time.current
    save!(validate: false)
  end

  def clear_password_reset_token!
    update_columns(reset_password_token: nil, reset_password_sent_at: nil)
  end

  def password_reset_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > 1.hour.ago
  end

  # ---------------------------------------------------------------------------
  # Serialisation
  # ---------------------------------------------------------------------------

  def as_json(options = {})
    super(options.merge(
      except: [:password, :password_digest, :streak, :last_login, :refresh_token,
               :confirmation_token, :confirmation_sent_at,
               :reset_password_token, :reset_password_sent_at]
    ))
  end
end
