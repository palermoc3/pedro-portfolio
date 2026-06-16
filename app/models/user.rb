class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


          SERIE_A_CLUBS = [
    "Athletico Paranaense",
    "Atlético Mineiro",
    "Bahia",
    "Botafogo",
    "Bragantino",
    "Ceará",
    "Corinthians",
    "Cruzeiro",
    "Flamengo",
    "Fluminense",
    "Fortaleza",
    "Grêmio",
    "Internacional",
    "Juventude",
    "Mirassol",
    "Palmeiras",
    "Santos",
    "São Paulo",
    "Sport",
    "Vasco"
  ].freeze

  validates :name, :age, :club, presence: true
  validates :club, inclusion: { in: SERIE_A_CLUBS, message: "deve ser um time da Série A" }
  
  before_validation :normalize_club

  private

  def normalize_club
    return if club.blank?
    # Normalize spacing and capitalization to match SERIE_A_CLUBS
    self.club = club.to_s.strip.titleize
  end
end
