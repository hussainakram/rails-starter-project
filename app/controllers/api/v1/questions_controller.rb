module Api
  module V1
    # For handling all requests regading question
    class QuestionsController < ApiController
      before_action :doorkeeper_authorize!
      before_action :set_question, only: %i[show update destroy]

      def index
        page = (params[:page] || 1)

        @questions = Question.all.order(created_at: :desc)
        @questions = @questions.joins(:tags).where('tags.name IN (?)', params[:tags]) if params[:tags]

        render json: @questions.page(page)
      end

      def show
        render json: @question
      end

      def create
        @question = current_user.questions.new(question_params)

        if @question.save
          render json: @question, status: :created, location: api_v1_question_url(@question)
        else
          render json: @question.errors, status: :unprocessable_entity
        end
      end

      def update
        if @question.update(question_params)
          render json: @question
        else
          render json: @question.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if current_user == @question.user
          render json: @question.destroy
        else
          auth_errors = { not_owner: 'Only question owner can delete the question' }
          render json: auth_errors, status: :unprocessable_entity
        end
      end

      private

      def set_question
        @question = Question.friendly.find(params[:id])
      end

      def question_params
        params.require(:data).require(:attributes).permit(:title, :slug, :body)
      end
    end
  end
end
