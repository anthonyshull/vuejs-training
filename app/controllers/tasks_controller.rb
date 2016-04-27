class TasksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @params = tasks_params.to_h
    if !@params['task'] || !@params['board']
      return false
    end
    Task.create board_id: @params['board'], description: @params['task']
    render json: 'ok'
  end

  def destroy
    Task.find(params[:id]).destroy
    render json: 'ok'
  end

  def update
    @params = tasks_params.to_h
    if !@params['board']
      return false
    end
    Task.find(params[:id]).update(board_id: @params['board'])
    render json: 'ok'
  end

  private

  def tasks_params
    params.permit(:board, :task)
  end
end