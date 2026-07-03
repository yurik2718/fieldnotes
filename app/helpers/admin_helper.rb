module AdminHelper
  def admin_card(title: nil, &block)
    tag.div class: "panel" do
      safe_join([
        title ? tag.h2(title) : nil,
        capture(&block)
      ].compact)
    end
  end

  def admin_toolbar(title:, &block)
    tag.div class: "toolbar" do
      safe_join([
        tag.h1(title),
        block ? capture(&block) : nil
      ].compact)
    end
  end

  def admin_error_list(record)
    return unless record.errors.any?

    tag.div class: "error-list" do
      safe_join(record.errors.map { tag.p(it.full_message) })
    end
  end
end
