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
end
