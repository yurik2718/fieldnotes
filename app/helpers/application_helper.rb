module ApplicationHelper
  def all_stylesheets
    Rails.root.glob("app/assets/stylesheets/**/*.css").map { it.basename(".css").to_s }.sort
  end

  def nav_link(label, path, controller:)
    active = controller_path.end_with?(controller)
    link_to label, path, class: class_names("nav-link", "nav-link--active": active),
                         aria: { current: ("page" if active) }
  end

  def admin_nav_link(label, path, controller:)
    active = controller_name.in?(Array(controller))
    link_to label, path, class: class_names("admin-nav__link", "admin-nav__link--active": active),
                         aria: { current: ("page" if active) }
  end

  def meta_tags(title:, description:, image: nil, type: :website, published_at: nil)
    render "shared/meta_tags",
      title: title,
      description: description,
      image: image,
      type: type,
      published_at: published_at
  end

  def picture_tag(attachment, alt:, sizes: "(max-width: 768px) 100vw, 90vw", loading: "lazy")
    return "" unless attachment.attached?

    srcset = [
      "#{url_for(attachment.variant(:medium))} 800w",
      "#{url_for(attachment.variant(:full))}   1920w",
      "#{url_for(attachment.variant(:retina))} 2560w"
    ].join(", ")

    tag.picture do
      concat tag.source(type: "image/avif", srcset: srcset, sizes: sizes)
      concat image_tag(attachment.variant(:full), alt: alt, loading: loading)
    end
  end

  def field_item_photo(item)
    item.watermarked_photo.attached? ? item.watermarked_photo : item.photo
  end

  BADGE_VARIANTS = {
    reading:   "badge--purple",
    completed: "badge--green",
    published: "badge--green",
    active:    "badge--green",
    draft:     "badge--amber",
    paused:    "badge--amber",
    mixed:     "badge--amber",
    photo:     "badge--blue",
    video:     "badge--purple"
  }.freeze

  def badge(status)
    tag.span status.to_s.capitalize, class: class_names("badge", BADGE_VARIANTS[status.to_sym])
  end
end
