class HomeAction < Cramp::Action
  def start
    render "Localhook/1.0.0"
    finish
  end
end
