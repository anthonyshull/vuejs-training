class BoardsController < ApplicationController

  def index
    @boards = Board.all.includes(:tasks).order(:id)
  end

end