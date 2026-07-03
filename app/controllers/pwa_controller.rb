class PwaController < ApplicationController
  allow_unauthenticated_access

  def manifest
    render layout: false
  end
end
