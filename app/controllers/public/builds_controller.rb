class Public::BuildsController < Public::BaseController
  def index
    @builds  = Build.not_archived.ordered
    @profile = Profile.instance
    fresh_when etag: [ @builds, @profile ]
  end
end
